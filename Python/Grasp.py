import json
import sys
from PyQt5.QtWidgets import QMainWindow, QApplication, QWidget, QDesktopWidget, QPushButton, QTabWidget, QVBoxLayout, \
    QLabel, QScrollArea, QProgressBar
from PyQt5.QtGui import QFont
from PyQt5.QtCore import Qt


class Login(QWidget):

    def __init__(self):
        super().__init__()
        self.width = 800
        self.height = 500
        self.screen = QDesktopWidget().screenGeometry()

        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Grasp Login')
        self.setFixedSize(self.width, self.height)
        self.move((self.screen.width() - self.width) / 2, (self.screen.height() - self.height) / 2)

        login_button = QPushButton('Create Account', self)
        login_button.resize(login_button.sizeHint())
        login_button.move((self.width - login_button.width()) / 2, (self.height - login_button.height()) / 2)
        login_button.clicked.connect(self.open_main_wrapper)

        self.show()

    def open_main_wrapper(self):
        self.open_main()

    def open_main(self):
        self.hide()
        main.show()


class Main(QMainWindow):

    def __init__(self):
        super().__init__()
        self.width = 800
        self.height = 500
        self.screen = QDesktopWidget().screenGeometry()

        self.table_widget = Table(self)
        self.setCentralWidget(self.table_widget)

        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Grasp')
        self.setFixedSize(self.width, self.height)
        self.move((self.screen.width() - self.width) / 2, (self.screen.height() - self.height) / 2)


class Table(QTabWidget):

    def __init__(self, parent):
        super(QTabWidget, self).__init__(parent)

        self.default_font = QFont('Menlo', 16)

        self.salary = QWidget()
        self.needs = QWidget()
        self.goals = QWidget()
        self.rain = QWidget()

        with open('Users/John.txt', 'r') as f:
            self.user = json.load(f)

        self.balance = int(self.user['monthly'])

        self.addTab(self.salary, 'Salary Overview')
        self.addTab(self.needs, 'Needs')
        self.addTab(self.goals, 'Goals')
        self.addTab(self.rain, 'Rainy Day')

        # Salary
        self.salary.layout = QVBoxLayout(self)
        self.salary.setLayout(self.salary.layout)
        self.salary_tab()

        # Needs
        self.needs.layout = QVBoxLayout(self)
        self.needs.setLayout(self.needs.layout)
        self.needs_tab()

        # Goals
        self.goals.layout = QVBoxLayout(self)
        self.goals.setLayout(self.goals.layout)
        self.goals_tab()

        # Rainy Day
        self.rain.layout = QVBoxLayout(self)
        self.rain.setLayout(self.rain.layout)
        self.rain_tab()

    def salary_tab(self):
        salary_font = QFont('Menlo', 36)

        salary_label = QLabel('Your monthly salary: ${:,.2f}'.format(float(self.user['monthly'])))
        salary_label.setFont(salary_font)
        salary_label.setStyleSheet('QLabel { color: rgb(0, 204, 0) }')
        self.salary.layout.addWidget(salary_label)
        salary_label.setAlignment(Qt.AlignCenter)

    def needs_tab(self):
        pass

    def goals_tab(self):

        def pay():
            pass

        def add():
            pass

        def remove():
            pass

        add = QPushButton('Add Goal', self.goals)
        add.move(10, 425)
        remove = QPushButton('Remove Goal', self.goals)
        remove.setGeometry(775 - remove.width(), 425, remove.width() + 5, remove.height())

        goals_scroll = QScrollArea(self.goals)
        goals_scroll.setGeometry(0, 0, 800, 400)
        goals_scroll.layout = QVBoxLayout(self.goals)
        goals_scroll.layout.addStretch()
        goals_scroll.setLayout(goals_scroll.layout)

        for goal, goal_data in self.user['goals'].items():
            temp_label = QLabel('{} (${:,.2f}/${:,.2f})'.format(goal, float(goal_data['paid']), float(goal_data['amount'])))
            temp_label.setFont(self.default_font)
            goals_scroll.layout.insertWidget(goals_scroll.layout.count() - 1, temp_label, 0, Qt.AlignCenter)

            temp_bar = QProgressBar(self.goals)
            temp_bar.setFixedSize(300, 20)
            temp_bar.setValue(100 * float(goal_data['paid']) / float(goal_data['amount']))
            goals_scroll.layout.insertWidget(goals_scroll.layout.count() - 1, temp_bar, 0, Qt.AlignCenter)

            temp_button = QPushButton('Pay', self.goals)
            temp_button.clicked.connect(pay)
            goals_scroll.layout.insertWidget(goals_scroll.layout.count() - 1, temp_button, 0, Qt.AlignCenter)




    def rain_tab(self):
        pass


if __name__ == '__main__':

    with open('Users/John.txt', 'w') as f:
        data = {'name': 'John', 'monthly': '10000', 'age': '30', 'password': 'password',
                'needs': {'rent': '1000', 'food': '400'},
                'goals': {'Car': {'amount': '20000', 'paid': '300'},
                          'Phone': {'amount': '1000', 'paid': '100'}}}
        json.dump(data, f, indent=4)

    app = QApplication(sys.argv)

    login = Login()

    main = Main()

    sys.exit(app.exec_())
