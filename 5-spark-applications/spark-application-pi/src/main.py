import sys
import os
import importlib
import logging
from random import random
from operator import add

from pyspark.sql import SparkSession
from pyspark import SparkConf

logging.basicConfig()
logger = logging.getLogger("demo-model-s3")
logger.setLevel(logging.DEBUG)
logger.debug('Enabled DEBUG')

# Debug lines - in case we need to debug in production
logger.debug(os.path.abspath(__file__))
logger.debug(sys.path)

# Setup sparkSession
spark_session = SparkSession.builder.getOrCreate()

# Log spark config - in case we need to debug in production
logger.debug(SparkConf().getAll())
hadoopConf = {}
iterator = spark_session.sparkContext._jsc.hadoopConfiguration().iterator()
while iterator.hasNext():
    prop = iterator.next()
    hadoopConf[prop.getKey()] = prop.getValue()
for item in sorted(hadoopConf.items()): logger.debug(item)

partitions = 2
n = 100000 * partitions

def f(_):
    x = random() * 2 - 1
    y = random() * 2 - 1
    return 1 if x ** 2 + y ** 2 <= 1 else 0

count = spark_session.sparkContext.parallelize(range(1, n + 1), partitions).map(f).reduce(add)
logger.info("Pi is roughly %f" % (4.0 * count / n))

spark_session.stop()
