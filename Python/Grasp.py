import json
import sys
from PyQt5.QtWidgets import QMainWindow, QApplication, QWidget, QDesktopWidget, QPushButton, QTabWidget, QVBoxLayout, \
    QLabel, QScrollArea, QProgressBar, QInputDialog, QErrorMessage
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

        self.goal_list = {}

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

        salary_label = QLabel('Your monthly salary: ${:,.2f}'.format(self.user['monthly']))
        salary_label.setFont(salary_font)
        salary_label.setStyleSheet('QLabel { color: rgb(0, 204, 0) }')
        self.salary.layout.addWidget(salary_label)
        salary_label.setAlignment(Qt.AlignCenter)

    def needs_tab(self):
        pass

    def goals_tab(self):

        add = QPushButton('Add Goal', self.goals)
        add.move(10, 425)
        add.clicked.connect(self.add_)

        remove = QPushButton('Remove Goal', self.goals)
        remove.setGeometry(775 - remove.width(), 425, remove.width() + 5, remove.height())
        remove.clicked.connect(self.remove_)

        pay = QPushButton('Pay', self.goals)
        pay.clicked.connect(self.pay_)
        pay.setGeometry((800 - pay.width()) / 2, 425, pay.width() + 5, pay.height())

        self.goals_scroll = QScrollArea(self.goals)
        self.goals_scroll.setGeometry(0, 0, 800, 400)
        self.goals_scroll.layout = QVBoxLayout(self.goals)
        self.goals_scroll.layout.addStretch()
        self.goals_scroll.setLayout(self.goals_scroll.layout)

        self.refresh_goals()

    def refresh_goals(self):
        for goal, goal_data in self.user['goals'].items():
            if goal not in self.goal_list.keys():
                temp_label = QLabel(
                    '{} (${:,.2f}/${:,.2f})'.format(goal, goal_data['paid'], goal_data['amount']))
                temp_label.setFont(self.default_font)
                self.goals_scroll.layout.insertWidget(self.goals_scroll.layout.count() - 1, temp_label, 0, Qt.AlignCenter)

                temp_bar = QProgressBar(self.goals)
                temp_bar.setFixedSize(300, 20)
                temp_bar.setValue(100 * goal_data['paid'] / goal_data['amount'])
                self.goals_scroll.layout.insertWidget(self.goals_scroll.layout.count() - 1, temp_bar, 0, Qt.AlignCenter)

                self.goal_list[goal] = (temp_label, temp_bar)
            else:
                self.goal_list[goal][1].setValue(min(100 * goal_data['paid'] / goal_data['amount'], 100))
                self.goal_list[goal][0].setText(
                    '{} (${:,.2f}/${:,.2f})'.format(goal, goal_data['paid'], goal_data['amount']))
        print(self.balance)

    def pay_(self):
        goals = self.user['goals'].keys()
        goal_to_pay, ok1 = QInputDialog.getItem(self, 'Select Goal', '', goals, 0, False)
        if ok1:
            amount, ok2 = QInputDialog.getInt(self, 'Pay amount', '$')
            if ok2:
                try:
                    amount_left = self.user['goals'][goal_to_pay]['amount'] - self.user['goals'][goal_to_pay]['paid']
                    if self.balance - min(amount_left, amount) < 0:
                        self.error()
                    else:
                        self.user['goals'][goal_to_pay]['paid'] += min(amount_left, amount)
                        self.balance -= min(amount_left, amount)
                        self.refresh_goals()
                except:
                    self.error('Error: Account balance (${:,.2f}) insufficient'.format(self.balance))

    def add_(self):
        goal, ok1 = QInputDialog.getText(self, 'Input a new goal', '')
        if ok1:
            amount, ok2 = QInputDialog.getInt(self, 'Input goal amount', '$')
            if ok2:
                try:
                    self.user['goals'][goal] = {'amount': amount, 'paid': 0}
                    self.refresh_goals()
                except:
                    self.error('Error: Could not add goal.')

    def remove_(self):
        goals = self.user['goals'].keys()
        goal, ok1 = QInputDialog.getItem(self, 'Remove Goal', '', goals, 0, False)
        if ok1:
            try:
                del self.user['goals'][goal]
                self.goals_scroll.layout.removeWidget(self.goal_list[goal][0])
                self.goals_scroll.layout.removeWidget(self.goal_list[goal][1])
                self.goal_list[goal][0].deleteLater()
                self.goal_list[goal][1].deleteLater()
                del self.goal_list[goal]
                self.refresh_goals()
            except:
                self.error('Error: Goal not found.')

    def rain_tab(self):
        pass

    def error(self, message):
        print(message)
        msg = QErrorMessage(self)
        msg.showMessage(message)


if __name__ == '__main__':

    with open('Users/John.txt', 'w') as f:
        data = {'name': 'John', 'monthly': 10000, 'age': 30, 'password': 'password',
                'needs': {'rent': 1000, 'food': 400},
                'goals': {'Car': {'amount': 20000, 'paid': 300},
                          'Phone': {'amount': 1000, 'paid': 100}}}
        json.dump(data, f, indent=4)

    app = QApplication(sys.argv)

    login = Login()

    main = Main()

    sys.exit(app.exec_())
