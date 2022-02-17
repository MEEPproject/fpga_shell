import time, re, sys, os, serial, inspect

class clr:
    RED     = '\033[31m'
    YELLOW  = '\033[33m'
    BLUE    = '\033[34m'
    CYAN    = '\033[36m'
    RST_CLR = '\033[0m'

def getFuncLine():
    # stack: [0] - current, [1] - print_* function, [2] - program
    frame_record = inspect.stack()[2]
    frame = frame_record[0]
    info = inspect.getframeinfo(frame)
    fname_short = info.filename.split('/')[-1]
    retval = "%s:%3d" % (fname_short, info.lineno)
    return retval

def split(word):
    return [char for char in word]


def configureUART(port):
    
    UART_BAUD_RATE=115200

    print_info("UART will be configured for %d baud rate" % UART_BAUD_RATE)
    port_full = '/dev/' + port


    try:
        ser = serial.Serial (
            port=port_full,
            baudrate=UART_BAUD_RATE,
            bytesize=serial.EIGHTBITS,
            parity=serial.PARITY_NONE,
            stopbits=serial.STOPBITS_ONE,
            timeout=0
        )
    except:
        print_error("Can not open serial device %s" % port_full)
        print_error("Provide correct device name using -p option")
        return None

    return ser

def writeSTDOUT(s):
    sys.stdout.write(s)
    sys.stdout.flush()

def loadCommand(ser):

    serial_command = sys.argv[1]

    #serial_command = "top"
    cr = "\r"
    #command_len = len(serial_command)
    list_char = split(serial_command) 
    writeSTDOUT("\nLoading a command...\n\n")

    for char in list_char:
        
        print("\nLoading a letter...%s\n", char)
        ser.write(char.encode())
        time.sleep(0.2)

    ser.write(cr.encode())

    return 0

def print_info(msg, fstream=sys.stderr):
    msg_print = clr.BLUE + "[INFO]  " + getFuncLine() + clr.RST_CLR + ": " + msg
    print(msg_print, file=fstream)


def main():

    ser = configureUART("ttyUSB2")

    if ser == None:
        return 0

    writeSTDOUT("\nStarting...\n\n")
    loadCommand(ser)

    if ser != None:
        ser.close()


if __name__ == '__main__':
    main()
