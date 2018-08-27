import log4p
import os
import logging
def fun1():
    SCRIPT_NAME = os.path.basename(__file__)
    print(SCRIPT_NAME)
    config = "log4p.json"
    print(config)
    pLogger = log4p.GetLogger(SCRIPT_NAME, logging.DEBUG, config).get_l()
    pLogger.debug("Type some log.")
    pLogger.error("error log")
    pLogger.info("info log")
fun1()
