import sys
import os
import importlib
import logging
from random import random
from operator import add

from pyspark.sql import SparkSession
from pyspark import SparkConf

logging.basicConfig()
logger = logging.getLogger("demo-read-secret")
logger.setLevel(logging.DEBUG)
logger.debug('Enabled DEBUG')

# Debug lines - in case we need to debug in production
logger.debug(os.path.abspath(__file__))
logger.debug(sys.path)
logger.debug(os.environ)

# Setup sparkSession
spark_session = SparkSession.builder.getOrCreate()

# Log spark config - in case we need to debug in production
logger.debug(SparkConf().getAll())

with open('/etc/secrets/accesskey') as f:
    lines = [line.rstrip('\n') for line in f]
    logger.info(lines)

spark_session.stop()
