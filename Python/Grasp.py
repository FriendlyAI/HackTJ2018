import json
import sys
from os import listdir

from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont
from PyQt5.QtWidgets import QMainWindow, QApplication, QWidget, QDesktopWidget, QPushButton, QTabWidget, QVBoxLayout, \
    QLabel, QScrollArea, QProgressBar, QInputDialog, QErrorMessage, QLineEdit


class Login(QMainWindow):

    def __init__(self):
        super().__init__()
        self.width = 800
        self.height = 500
        self.screen = QDesktopWidget().screenGeometry()

        self.create_account_label = QLabel(self)
        self.name = QLabel(self)
        self.name_line = QLineEdit(self)
        self.monthly_salary = QLabel(self)
        self.monthly_salary_line = QLineEdit(self)
        self.password = QLabel(self)
        self.password_line = QLineEdit(self)

        self.create_account_button = QPushButton('Create Account', self)

        self.login_label = QLabel(self)
        self.login_name = QLabel(self)
        self.login_name_line = QLineEdit(self)
        self.login_password = QLabel(self)
        self.login_password_line = QLineEdit(self)

        self.login_button = QPushButton('Login', self)

        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Grasp Login')
        self.setFixedSize(self.width, self.height)
        self.move((self.screen.width() - self.width) / 2, (self.screen.height() - self.height) / 2)

        # Create Account

        self.create_account_label.setText('Create an Account')
        self.create_account_label.resize(self.create_account_label.sizeHint())
        self.create_account_label.move((self.width - self.create_account_label.width()) / 2, 25)

        self.name.setText('Name:')
        self.name_line.resize(150, 20)
        self.name_line.move((self.width - self.name_line.width()) / 2, 50)
        self.name.move((self.width - self.name_line.width()) / 2 - self.name.width(), 45)

        self.monthly_salary.setText('Monthly Salary:')
        self.monthly_salary_line.resize(150, 20)
        self.monthly_salary_line.move((self.width - self.monthly_salary_line.width()) / 2, 75)
        self.monthly_salary.move((self.width - self.monthly_salary_line.width()) / 2 - self.monthly_salary.width(), 70)

        self.password.setText('Password:')
        self.password_line.setEchoMode(QLineEdit.Password)
        self.password_line.resize(150, 20)
        self.password_line.move((self.width - self.password_line.width()) / 2, 100)
        self.password.move((self.width - self.password_line.width()) / 2 - self.password.width(), 95)

        self.create_account_button.resize(self.create_account_button.sizeHint())
        self.create_account_button.move((self.width - self.create_account_button.width()) / 2, 125)
        self.create_account_button.clicked.connect(self.create_account_wrapper)

        # Login

        self.login_label.setText('Login')
        self.login_label.resize(self.login_label.sizeHint())
        self.login_label.move((self.width - self.login_label.width()) / 2, 200)

        self.login_name.setText('Name:')
        self.login_name_line.resize(150, 20)
        self.login_name_line.move((self.width - self.login_name_line.width()) / 2, 225)
        self.login_name.move((self.width - self.login_name_line.width()) / 2 - self.login_name.width(), 220)

        self.login_password.setText('Password:')
        self.login_password_line.setEchoMode(QLineEdit.Password)
        self.login_password_line.resize(150, 20)
        self.login_password_line.move((self.width - self.login_password_line.width()) / 2, 250)
        self.login_password.move((self.width - self.login_password_line.width()) / 2 - self.login_password.width(), 245)

        self.login_button.resize(self.login_button.sizeHint())
        self.login_button.move((self.width - self.login_button.width()) / 2, 275)
        self.login_button.clicked.connect(self.login_wrapper)

        self.show()

    def create_account_wrapper(self):

        if f'{self.name_line.text()}.json' in listdir('Users'):
            msg = QErrorMessage(self)
            msg.showMessage('Error: User already exists.')
        else:
            try:
                with open(f'Users/{self.name_line.text()}.json', 'w+') as file:
                    user_dict = {
                        'name': f'{self.name_line.text()}',
                        'monthly': float(self.monthly_salary_line.text()),
                        'password': f'{self.password_line.text()}',
                        'needs': {},
                        'goals': {},
                        'savings': 0
                    }
                    json.dump(user_dict, file, indent=4)
            except ValueError:
                msg = QErrorMessage(self)
                msg.showMessage('Error: invalid account creation information.')
        if not self.password_line.text() or not self.monthly_salary_line.text():
            msg = QErrorMessage(self)
            msg.showMessage('Error: invalid account creation information.')
        else:
            self.open_main(self.name_line.text())

    def login_wrapper(self):
        try:
            with open(f'Users/{self.login_name_line.text()}.json', 'r') as file:
                if json.load(file)['password'] != self.login_password_line.text():
                    msg = QErrorMessage(self)
                    msg.showMessage('Error: Username or password incorrect')
                else:
                    self.open_main(self.login_name_line.text())
        except FileNotFoundError:
            msg = QErrorMessage(self)
            msg.showMessage('Error: Username or password incorrect.')

    def open_main(self, name):
        self.main = Main(name)
        self.main.show()
        self.hide()


class Main(QMainWindow):

    def __init__(self, name):
        super().__init__()

        self.width = 800
        self.height = 500
        self.screen = QDesktopWidget().screenGeometry()

        self.table_widget = Table(self, name)
        self.setCentralWidget(self.table_widget)

        self.init_ui()

    def init_ui(self):
        self.setWindowTitle('Grasp')
        self.setFixedSize(self.width, self.height)
        self.move((self.screen.width() - self.width) / 2, (self.screen.height() - self.height) / 2)


class Table(QTabWidget):

    def __init__(self, parent, name):
        super(QTabWidget, self).__init__(parent)

        self.default_font = QFont('Menlo', 16)

        self.salary = QWidget()
        self.needs = QWidget()
        self.goals = QWidget()
        self.rain = QWidget()

        self.goal_list = {}
        self.need_list = {}

        self.name = name

        with open(f'Users/{self.name}.json', 'r') as file:
            self.user = json.load(file)

        self.balance = self.user['monthly']
        self.salary_label = QLabel('Your monthly salary: ${:,.2f}'.format(self.user['monthly']))
        self.balance_label = QLabel('Your monthly remaining balance: ${:,.2f}'.format(self.balance))
        self.user['savings'] += self.balance
        self.rainy_day = QLabel('Your rainy day fund: ${:,.2f}'.format(self.user['savings']))

        self.addTab(self.salary, 'Overview')
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
        balance_font = QFont('Menlo', 18)

        self.salary_label.setFont(salary_font)
        self.salary_label.setStyleSheet('QLabel { color: rgb(0, 204, 0) }')
        self.salary.layout.addWidget(self.salary_label)
        self.salary_label.setAlignment(Qt.AlignCenter)

        self.balance_label.setFont(balance_font)
        self.balance_label.setStyleSheet('QLabel { color: rgb(0, 204, 0) }')
        self.salary.layout.addWidget(self.balance_label)
        self.balance_label.setAlignment(Qt.AlignCenter)

    def needs_tab(self):

        add = QPushButton('Add Need', self.needs)
        add.move(10, 425)
        add.clicked.connect(self.add_need)

        remove = QPushButton('Remove Need', self.needs)
        remove.setGeometry(775 - remove.width(), 425, remove.width() + 10, remove.height())
        remove.clicked.connect(self.remove_need)

        self.needs_scroll = QScrollArea(self.needs)
        self.needs_scroll.setGeometry(0, 0, 800, 400)
        self.needs_scroll.layout = QVBoxLayout(self.needs)
        self.needs_scroll.layout.addStretch()
        self.needs_scroll.setLayout(self.needs_scroll.layout)

        self.refresh_needs()
        self.balance_label.setText('Your monthly remaining balance: ${:,.2f}'.format(self.balance))
        self.rainy_day.setText('Your rainy day fund: ${:,.2f}'.format(self.user['savings']))

    def refresh_needs(self):
        for need, need_amount in self.user['needs'].items():
            if need not in self.need_list.keys():
                temp_label = QLabel(
                    '{} (${:,.2f}/month)'.format(need, need_amount))
                temp_label.setFont(self.default_font)
                self.needs_scroll.layout.insertWidget(self.needs_scroll.layout.count() - 1, temp_label, 0,
                                                      Qt.AlignCenter)
                temp_bar = QProgressBar(self.needs)
                temp_bar.setFixedSize(300, 20)
                temp_bar.setValue(min(100 * self.balance / need_amount, 100))
                self.balance -= need_amount
                self.user['savings'] -= need_amount
                if self.balance < 0:
                    self.error('You don\'t have enough money to pay for your needs!')
                self.needs_scroll.layout.insertWidget(self.needs_scroll.layout.count() - 1, temp_bar, 0, Qt.AlignCenter)

                self.need_list[need] = (temp_label, temp_bar)
            else:
                self.need_list[need][1].setValue(min(100 * self.balance / need_amount, 100))
                self.need_list[need][0].setText(
                    '{} (${:,.2f}/month)'.format(need, need_amount))

        self.refresh_data()

    def add_need(self):
        need, ok1 = QInputDialog.getText(self, 'Input a new need', '')
        if ok1:
            amount, ok2 = QInputDialog.getInt(self, 'Input need amount/month', '$')
            if ok2:
                try:
                    if need in self.user['needs'].keys():
                        self.error('Error: Need already exists.')
                    else:
                        self.user['needs'][need] = amount
                        self.refresh_needs()
                        self.balance_label.setText('Your monthly remaining balance: ${:,.2f}'.format(self.balance))
                        self.rainy_day.setText('Your rainy day fund: ${:,.2f}'.format(self.user['savings']))
                except:
                    self.error('Error: Could not add need.')

    def remove_need(self):
        needs = self.user['needs'].keys()
        need, ok1 = QInputDialog.getItem(self, 'Remove Need', '', needs, 0, False)
        if ok1:
            try:
                self.balance += self.user['needs'][need]
                del self.user['needs'][need]
                self.needs_scroll.layout.removeWidget(self.need_list[need][0])
                self.needs_scroll.layout.removeWidget(self.need_list[need][1])
                self.need_list[need][0].deleteLater()
                self.need_list[need][1].deleteLater()
                del self.need_list[need]
                self.balance_label.setText('Your monthly remaining balance: ${:,.2f}'.format(self.balance))
                self.rainy_day.setText('Your rainy day fund: ${:,.2f}'.format(self.user['savings']))
                self.refresh_needs()
            except:
                self.error('Error: Need not found.')

    def goals_tab(self):

        add = QPushButton('Add Goal', self.goals)
        add.move(10, 425)
        add.clicked.connect(self.add_goal)

        remove = QPushButton('Remove Goal', self.goals)
        remove.setGeometry(775 - remove.width(), 425, remove.width() + 5, remove.height())
        remove.clicked.connect(self.remove_goal)

        pay = QPushButton('Pay', self.goals)
        pay.clicked.connect(self.pay_goal)
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
                self.goals_scroll.layout.insertWidget(self.goals_scroll.layout.count() - 1, temp_label, 0,
                                                      Qt.AlignCenter)

                temp_bar = QProgressBar(self.goals)
                temp_bar.setFixedSize(300, 20)
                temp_bar.setValue(100 * goal_data['paid'] / goal_data['amount'])
                self.goals_scroll.layout.insertWidget(self.goals_scroll.layout.count() - 1, temp_bar, 0, Qt.AlignCenter)

                self.goal_list[goal] = (temp_label, temp_bar)
            else:
                self.goal_list[goal][1].setValue(min(100 * goal_data['paid'] / goal_data['amount'], 100))
                self.goal_list[goal][0].setText(
                    '{} (${:,.2f}/${:,.2f})'.format(goal, goal_data['paid'], goal_data['amount']))
        self.refresh_data()

    def pay_goal(self):
        goals = self.user['goals'].keys()
        goal_to_pay, ok1 = QInputDialog.getItem(self, 'Select Goal', '', goals, 0, False)
        if ok1:
            amount, ok2 = QInputDialog.getInt(self, 'Pay amount', '$')
            if ok2:
                try:
                    amount_left = self.user['goals'][goal_to_pay]['amount'] - self.user['goals'][goal_to_pay]['paid']
                    if self.balance - min(amount_left, amount) < 0:
                        self.error('Error: Account balance (${:,.2f}) insufficient'.format(self.balance))
                    else:
                        self.user['goals'][goal_to_pay]['paid'] += min(amount_left, amount)
                        self.balance -= min(amount_left, amount)
                        self.user['savings'] -= min(amount_left, amount)
                        self.refresh_goals()
                        self.balance_label.setText('Your monthly remaining balance: ${:,.2f}'.format(self.balance))
                        self.rainy_day.setText('Your rainy day fund: ${:,.2f}'.format(self.user['savings']))
                except KeyError:
                    self.error('Error: Goal does not exist.')

    def add_goal(self):
        goal, ok1 = QInputDialog.getText(self, 'Input a new goal', '')
        if ok1:
            amount, ok2 = QInputDialog.getInt(self, 'Input goal amount', '$')
            if ok2:
                try:
                    self.user['goals'][goal] = {'amount': amount, 'paid': 0}
                    self.refresh_goals()
                except:
                    self.error('Error: Could not add goal.')

    def remove_goal(self):
        goals = self.user['goals'].keys()
        goal, ok1 = QInputDialog.getItem(self, 'Remove Goal', '', goals, 0, False)
        if ok1:
            try:
                self.balance += self.user['goals'][goal]['paid']
                del self.user['goals'][goal]
                self.goals_scroll.layout.removeWidget(self.goal_list[goal][0])
                self.goals_scroll.layout.removeWidget(self.goal_list[goal][1])
                self.goal_list[goal][0].deleteLater()
                self.goal_list[goal][1].deleteLater()
                del self.goal_list[goal]
                self.balance_label.setText('Your monthly remaining balance: ${:,.2f}'.format(self.balance))
                self.rainy_day.setText('Your rainy day fund: ${:,.2f}'.format(self.user['savings']))
                self.refresh_goals()
            except:
                self.error('Error: Goal not found.')

    def rain_tab(self):
        salary_font = QFont('Menlo', 36)

        self.rainy_day.setFont(salary_font)
        self.rainy_day.setStyleSheet('QLabel { color: rgb(0, 0, 204) }')
        self.rain.layout.addWidget(self.rainy_day)
        self.rainy_day.setAlignment(Qt.AlignCenter)

    def error(self, message):
        msg = QErrorMessage(self)
        msg.showMessage(message)

    def refresh_data(self):
        with open(f'Users/{self.name}.json', 'w') as file:
            json.dump(self.user, file, indent=4)


if __name__ == '__main__':
    with open('Users/John.json', 'w') as f:
        data = {'name': 'John',
                'monthly': 10000,
                'password': 'password',
                'needs': {'Rent': 1000, 'Food': 400},
                'goals': {'Car': {'amount': 20000, 'paid': 300},
                          'Phone': {'amount': 1000, 'paid': 100},
                          'Mortgage': {'amount': 300000, 'paid': 75000}},
                'savings': 1000
                }
        json.dump(data, f, indent=4)

    app = QApplication(sys.argv)

    login = Login()

    sys.exit(app.exec_())
