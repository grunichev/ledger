DB_PATH = "/home/vtitov/projects/ledger/ledger.sqlite"
CALC_TOLERANCE = 10e-9

# PREDEFINED BOOK ACCOUNTS
#TODO Load from "books" table
BOOK_ACCOUNT_COSTS          = 1
BOOK_ACCOUNT_INCOMES        = 2
BOOK_ACCOUNT_MONEY          = 3
BOOK_ACCOUNT_ACTIVES        = 4
BOOK_ACCOUNT_LIABILITIES    = 5
BOOK_ACCOUNT_TRANSFERS      = 6

# PREDEFINED TRANSACTION TYPES
TRANSACTION_ACTION      = 1
TRANSACTION_DIVIDEND    = 2
TRANSACTION_TRADE       = 3

# PREDEFINED CATEGORIES
CATEGORY_TRANSFER_IN    = 107
CATEGORY_TRANSFER_OUT   = 108
CATEGORY_FEES           = 109
CATEGORY_TAXES          = 110
CATEGORY_DIVIDEND       = 111
CATEGORY_PROFIT         = 114

# PREDEFINED CURRENCY
CURRENCY_RUBLE = 15

from PySide2.QtGui import QColor
DARK_GREEN_COLOR = QColor(0, 100, 0)
DARK_RED_COLOR = QColor(139, 0, 0)
DARK_BLUE_COLOR = QColor(0, 0, 139)