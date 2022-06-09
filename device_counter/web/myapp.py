from flask import Flask, render_template
import os

app = Flask(__name__)


def sum_counted():
    '''
    use this function to read both files with the integers, and put them into variables.
    '''
    sum = open('/home/kali/Desktop/device_counter/countedmacs.txt','r') 
    return sum.read()

@app.route('/')
def myapp():
    sum = sum_counted()
    return render_template('index.html', sum_to_represent=sum)

