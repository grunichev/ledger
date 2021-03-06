import uuid
import json
import logging
import requests
from urllib import parse
from datetime import datetime

from PySide2.QtCore import Signal, Slot, QUrl
from PySide2.QtWidgets import QDialog
from PySide2.QtWebEngineWidgets import QWebEngineProfile, QWebEnginePage
from PySide2.QtWebEngineCore import QWebEngineUrlRequestInterceptor
from DB.helpers import readSQL, executeSQL
from CustomUI.helpers import g_tr
from UI.ui_login_fns_dlg import Ui_LoginFNSDialog


#-----------------------------------------------------------------------------------------------------------------------
class RequestInterceptor(QWebEngineUrlRequestInterceptor):
    response_intercepted = Signal(str, str)

    def __init__(self):
        super().__init__()
        self.session = None

    # At successful login ESIA page will give Response '302 Found' with URL to irkkt-mobile.nalog.ru which
    # contains authorization results. We can't intercept response so we block next request and
    # get parameters from it. Then communicate it via 'response_intercepted' signal
    def interceptRequest(self, info):
        url = info.firstPartyUrl().url()    # Get intercepted URL
        if str.startswith(url, "https://irkkt-mobile.nalog.ru:8888/"):
            info.block(True)
            params = dict(parse.parse_qsl(parse.urlsplit(url).query))
            auth_code = params['code']
            auth_state = params['state']
            logging.info(g_tr('SlipsTaxAPI', "ESIA login completed"))
            self.response_intercepted.emit(auth_code, auth_state)


#-----------------------------------------------------------------------------------------------------------------------
class LoginFNS(QDialog, Ui_LoginFNSDialog):
    def __init__(self, db, parent=None):
        QDialog.__init__(self, parent=parent)
        self.setupUi(self)
        self.db = db

        self.web_session = requests.Session()
        self.web_profile = QWebEngineProfile()
        self.web_interceptor = RequestInterceptor()
        self.web_interceptor.response_intercepted.connect(self.response_esia)
        self.web_profile.setRequestInterceptor(self.web_interceptor)
        self.ESIAWebView.setPage(QWebEnginePage(self.web_profile, self))

        self.LoginMethodTabs.currentChanged.connect(self.on_tab_changed)
        self.FNSLoginBtn.clicked.connect(self.login_fns)

    def on_tab_changed(self, index):
        if index == 1: # ESIA login selected
            self.login_esia()

    def login_fns(self):
        client_secret = readSQL(self.db, "SELECT value FROM settings WHERE name='RuTaxClientSecret'")
        inn = self.InnEdit.text()
        password = self.PasswordEdit.text()

        s = requests.Session()
        s.headers['ClientVersion'] = '2.9.0'
        s.headers['Device-Id'] = str(uuid.uuid1())
        s.headers['Device-OS'] = 'Android'
        s.headers['Content-Type'] = 'application/json; charset=UTF-8'
        s.headers['Accept-Encoding'] = 'gzip'
        s.headers['User-Agent'] = 'okhttp/4.2.2'
        payload = '{' + f'"client_secret":"{client_secret}","inn":"{inn}","password":"{password}"' + '}'
        response = s.post('https://irkkt-mobile.nalog.ru:8888/v2/mobile/users/lkfl/auth', data=payload)
        if response.status_code != 200:
            logging.error(g_tr('SlipsTaxAPI', "FNS login failed: ") + f"{response}/{response.text}")
            return
        logging.info(g_tr('SlipsTaxAPI', "FNS login successful: ") + f"{response.text}")
        json_content = json.loads(response.text)
        new_session_id = json_content['sessionId']
        new_refresh_token = json_content['refresh_token']
        _ = executeSQL(self.db, "UPDATE settings SET value=:new_session WHERE name='RuTaxSessionId'",
                       [(":new_session", new_session_id)])
        _ = executeSQL(self.db, "UPDATE settings SET value=:new_refresh_token WHERE name='RuTaxRefreshToken'",
                       [(":new_refresh_token", new_refresh_token)])
        self.db.commit()
        self.accept()

    def login_esia(self):
        self.web_session.headers['ClientVersion'] = '2.9.0'
        self.web_session.headers['Device-Id'] = str(uuid.uuid1())
        self.web_session.headers['Device-OS'] = 'Android'
        self.web_session.headers['Content-Type'] = 'application/json; charset=UTF-8'
        self.web_session.headers['Accept-Encoding'] = 'gzip'
        self.web_session.headers['User-Agent'] = 'okhttp/4.2.2'
        response = self.web_session.get('https://irkkt-mobile.nalog.ru:8888/v2/mobile/users/esia/auth/url')
        if response.status_code != 200:
            logging.error(g_tr('SlipsTaxAPI', "Get ESIA URL failed: ") + f"{response}/{response.text}")
            return
        json_content = json.loads(response.text)
        auth_url = json_content['url']
        self.ESIAWebView.load(QUrl(auth_url))

    @Slot()
    def response_esia(self, auth_code, state):
        client_secret = readSQL(self.db, "SELECT value FROM settings WHERE name='RuTaxClientSecret'")
        payload = '{' + f'"authorization_code": "{auth_code}", "client_secret": "{client_secret}", "state": "{state}"' \
                  + '}'
        response = self.web_session.post('https://irkkt-mobile.nalog.ru:8888/v2/mobile/users/esia/auth', data=payload)
        if response.status_code != 200:
            logging.error(g_tr('SlipsTaxAPI', "ESIA login failed: ") + f"{response}/{response.text}")
            return
        logging.info(g_tr('SlipsTaxAPI', "ESIA login successful: ") + f"{response.text}")
        json_content = json.loads(response.text)
        new_session_id = json_content['sessionId']
        new_refresh_token = json_content['refresh_token']
        _ = executeSQL(self.db, "UPDATE settings SET value=:new_session WHERE name='RuTaxSessionId'",
                       [(":new_session", new_session_id)])
        _ = executeSQL(self.db, "UPDATE settings SET value=:new_refresh_token WHERE name='RuTaxRefreshToken'",
                       [(":new_refresh_token", new_refresh_token)])
        self.db.commit()
        self.accept()

#-----------------------------------------------------------------------------------------------------------------------
class SlipsTaxAPI:
    def __init__(self, db):
        self.db = db

    def get_ru_tax_session(self):
        stored_id = readSQL(self.db, "SELECT value FROM settings WHERE name='RuTaxSessionId'")
        if stored_id != '':
            return stored_id

        login_dialog = LoginFNS(self.db)
        if login_dialog.exec_() == QDialog.Accepted:
            stored_id = readSQL(self.db, "SELECT value FROM settings WHERE name='RuTaxSessionId'")
            if stored_id is not None:
                return stored_id

        logging.warning(g_tr('SlipsTaxAPI', "No Russian Tax SessionId available"))
        return ''

    def refresh_session(self):
        session_id = self.get_ru_tax_session()
        client_secret = readSQL(self.db, "SELECT value FROM settings WHERE name='RuTaxClientSecret'")
        refresh_token = readSQL(self.db, "SELECT value FROM settings WHERE name='RuTaxRefreshToken'")
        s = requests.Session()
        s.headers['ClientVersion'] = '2.9.0'
        s.headers['Device-Id'] = str(uuid.uuid1())
        s.headers['Device-OS'] = 'Android'
        s.headers['sessionId'] = session_id
        s.headers['Content-Type'] = 'application/json; charset=UTF-8'
        s.headers['Accept-Encoding'] = 'gzip'
        s.headers['User-Agent'] = 'okhttp/4.2.2'
        payload = '{' + f'"client_secret":"{client_secret}","refresh_token":"{refresh_token}"' + '}'
        response = s.post('https://irkkt-mobile.nalog.ru:8888/v2/mobile/users/refresh', data=payload)
        if response.status_code == 200:
            logging.info(g_tr('SlipsTaxAPI', "Session refreshed: ") + f"{response.text}")
            json_content = json.loads(response.text)
            new_session_id = json_content['sessionId']
            new_refresh_token = json_content['refresh_token']
            _ = executeSQL(self.db, "UPDATE settings SET value=:new_session WHERE name='RuTaxSessionId'",
                           [(":new_session", new_session_id)])
            _ = executeSQL(self.db, "UPDATE settings SET value=:new_refresh_token WHERE name='RuTaxRefreshToken'",
                           [(":new_refresh_token", new_refresh_token)])
        else:
            logging.error(g_tr('SlipsTaxAPI', "Can't refresh session, response: ") + f"{response}/{response.text}")

    def get_slip(self, timestamp, amount, fn, fd, fp, slip_type):
        date_time = datetime.fromtimestamp(timestamp).strftime('%Y%m%dT%H%M%S')

        session_id = self.get_ru_tax_session()
        if session_id == '':
            return None
        s = requests.Session()
        s.headers['ClientVersion'] = '2.9.0'
        s.headers['Device-Id'] = str(uuid.uuid1())
        s.headers['Device-OS'] = 'Android'
        s.headers['sessionId'] = session_id
        s.headers['Content-Type'] = 'application/json; charset=UTF-8'
        s.headers['Accept-Encoding'] = 'gzip'
        s.headers['User-Agent'] = 'okhttp/4.2.2'
        payload = '{' + f'"qr": "t={date_time}&s={amount:.2f}&fn={fn}&i={fd}&fp={fp}&n={slip_type}"' + '}'
        response = s.post('https://irkkt-mobile.nalog.ru:8888/v2/ticket', data=payload)
        if response.status_code != 200:
            if response.status_code == 401 and response.text == "Session was not found":
                self.refresh_session()
            else:
                logging.error(
                    g_tr('SlipsTaxAPI', "Get ticket id failed: ") +
                    f"{response}/{response.text} for {payload}")
            return None
        logging.info(g_tr('SlipsTaxAPI', "Slip found: " + response.text))
        json_content = json.loads(response.text)
        if json_content['status'] != '2':  # Valid slip status is 2, other statuses are not fully clear
            logging.warning(g_tr('ImportSlipDialog', "Operation might be pending on server side. Try again later."))
            return None
        url = "https://irkkt-mobile.nalog.ru:8888/v2/tickets/" + json_content['id']
        response = s.get(url)
        if response.status_code != 200:
            logging.error(g_tr('SlipsTaxAPI', "Get ticket failed: ") + f"{response}/{response.text}")
            return None
        logging.info(g_tr('SlipsTaxAPI', "Slip loaded: " + response.text))
        slip_json = json.loads(response.text)
        return slip_json

    #----------------------------------------------------------------------------------------------------------------
    # Gets company name by Russian INN
    # Returns short or long name if fount and empty string otherwise
    def get_shop_name_by_inn(self, inn):
        if len(inn) != 10 and len(inn) != 12:
            logging.warning(g_tr('SlipsTaxAPI', "Incorrect legth of INN. Can't get company name."))
            return ''
        s = requests.Session()
        s.headers['User-Agent'] = 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:76.0) Gecko/20100101 Firefox/76.0'
        s.headers['Content-Type'] = "application/x-www-form-urlencoded"
        payload = f"vyp3CaptchaToken=&page=&query={inn}&region={inn[0]}{inn[1]}&PreventChromeAutocomplete="
        response = s.post('https://egrul.nalog.ru/', data=payload)
        if response.status_code != 200:
            logging.error(g_tr('SlipsTaxAPI', "Failed to get token for INN: ") + f"{response}/{response.text}")
            return ''
        result = json.loads(response.text)
        token = result['t']
        response = s.get('https://egrul.nalog.ru/search-result/' + token)
        if response.status_code != 200:
            logging.error(g_tr('SlipsTaxAPI', "Failed to get details about INN: ") + f"{response}/{response.text}")
            return ''
        result = json.loads(response.text)
        try:
            return result['rows'][0]['c']   # Return short name if exists
        except:
            pass
        try:
            return result['rows'][0]['n']   # Return long name if exists
        except:
            logging.warning(g_tr('SlipsTaxAPI', "Can't get company name from: ") + response.text)
            return ''