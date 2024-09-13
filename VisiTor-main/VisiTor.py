from Utils import *
from Utils import addressfinder, whereis, find_file, keypress, naturalmove
import argparse
import sys
import traceback
import logging
import tempfile


def error_handler(type, value, tb):
    error_msg = f"Python Error:\nType: {type}\nValue: {value}\nTraceback:\n{''.join(traceback.format_tb(tb))}"
    logging.error(error_msg)
    print(error_msg, file=sys.stderr)
    sys.exit(1)

sys.excepthook = error_handler

if __name__ == "__main__":
    try:
        parser = argparse.ArgumentParser(description="Lets automatically find stuff!")
        parser.add_argument('Function', type=str, help='The activity you want to do')
        parser.add_argument('--Dir', type=str, help='The directory for the files that the function will need')
        parser.add_argument('--arg2', type=str, nargs='+', help='Any argument of the function')
        args = parser.parse_args()
        logging.info(f"Parsed arguments: {args}")
        if args.Function == 'continuouspresskey':
            logging.info("Executing continuouspresskey function")
            if args.arg2 is None or len(args.arg2) == 0:
                args.arg2 = input('Please enter a key: ')
            key = args.arg2[0] if isinstance(args.arg2, list) else args.arg2
            logging.info("Attempting to press key: %s", key)
            longkeypress(key)
            logging.info("Key press completed for key: %s", key)
        elif args.Function == 'click':
            click()
        elif args.Function == 'Keypress':
            if args.arg2 == None:
                args.arg2 = input('Please enter a key')
                while len(args.arg2)!=1:
                    args.arg2 = input('Please enter a single key')
                keypress(args.arg2)
            else:
                while len(args.arg2)!=1:
                    args.arg2 = input('Please enter a single key')
                keypress(args.arg2)
        elif args.Function == 'whatisonscreen':
            flag =False
            if args.arg2 ==None:
                args.arg2 = input('Please enter enter Feedback visual modules seperated by space')
                args.arg2 = args.arg2.split()
            address = args.Dir
            for module in args.arg2:
                path = find_file(address, f'{module}')
                coor_choice = whereis(path)
                if type(coor_choice) ==tuple:
                    flag =True
                    print(f'{module}')
            if flag ==False:
                print('crap')
        elif args.Function == 'movecursorto':
            print(args.arg2)
            if args.arg2 == None:
                args.arg2 = input('Please enter x and y coordinates seperated by space')
                while len(args.arg2.split())!=2:
                    args.arg2 = input('Please enter x and y coordinates seperated by space')
            else:
                while len(args.arg2)!=2:
                    args.arg2 = input('Please enter x and y coordinates seperated by space')
            coor = (int(args.arg2[0]),int(args.arg2[1]))
            win32api.SetCursorPos(coor)
        elif args.Function == 'getMouseLocation':
            print(pyautogui.position())
        elif args.Function == 'whereis':
            if args.arg2 is None or len(args.arg2) == 0:
                args.arg2 = [input('Please enter the name of the file without extension: ')]

            # Join all elements of args.arg2 into a single string
            filename = ' '.join(args.arg2)

            # Use os.path.join to create the full path
            full_path = os.path.join(args.Dir, filename)
            print(f"Searching for file in directory: {args.Dir}")
            print(f"Full path being searched: {full_path}")

            result = whereis(full_path)
            print(f"RESULT: {result}")
        elif args.Function == "movecursortopattern":
            if args.Dir is None:
                args.Dir = addressfinder()
            while args.arg2 is None:
                args.arg2 = input('Please enter the name of the file without extention')
            address = args.Dir
            i = 0
            path = find_file(address,f'{args.arg2[0].lower()}')
            from PIL import Image
            im = Image.open(path)

            coor_choice =whereis(path)
            naturalmove((int(coor_choice[0]),int(coor_choice[1])))
        logging.info("VisiTor.py completed successfully")
    except Exception as e:
        logging.exception("An error occurred:")
        error_handler(type(e), e, sys.exc_info()[2])
