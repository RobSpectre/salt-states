from __future__ import unicode_literals
import multiprocessing

bind = "127.0.0.1:8000"
workers = multiprocessing.cpu_count() * 2 + 1 
errorlog = "/opt/adcap.biz/log/adcap.biz_error.log"
loglevel = "info"
preload_app = True
