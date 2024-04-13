#!/bin/bash

## Copyright (c) 2024 mangalbhaskar. All Rights Reserved.
##__author__ = 'mangalbhaskar'
###----------------------------------------------------------
#
## References:
## * https://www.digitalocean.com/community/tutorials/how-to-install-apache-kafka-on-ubuntu-18-04
###----------------------------------------------------------


function kafka-verify.main() {
  local LSCRIPTS=$( cd "$( dirname "${BASH_SOURCE[0]}")" && pwd )
  source ${LSCRIPTS}/lscripts.config.sh
  source ${LSCRIPTS}/kafka-utils.sh
  source ${LSCRIPTS}/core/argparse.sh "$@"

  [[ "$#" -ne "2" ]] && lsd-mod.log.fail "Invalid number of paramerters: required 2 given $#"
  [[ -n "${args['home']+1}" ]] && [[ -n "${args['username']+1}" ]] && {
    # (>&2 echo -e "key: 'username' exists")
    local KAFKA_HOME="${args['home']}"
    local KAFKA_USERNAME="${args['username']}"
    local KAFKA_CONFIG=${LSCRIPTS}/core/config/kafka/server.properties

    lsd-mod.log.info "KAFKA_HOME: ${KAFKA_HOME}"
    lsd-mod.log.info "KAFKA_USERNAME: ${KAFKA_USERNAME}"
    lsd-mod.log.info "KAFKA_CONFIG: ${KAFKA_CONFIG}"

    # su -l ${KAFKA_USERNAME}

    lsd-mod.log.info "Starting kafka..."
    __kafka-start ${KAFKA_HOME} ${KAFKA_CONFIG}

    [[ -f ${KAFKA_HOME}/bin/kafka-topics.sh ]] || (fail "File does not exists: ${KAFKA_HOME}/bin/kafka-topics.sh" && return -1)
    # [[ -f ${KAFKA_HOME}/bin/kafka-console-producer.sh ]] || lsd-mod.log.fail "File does not exists: ${KAFKA_HOME}/bin/kafka-console-producer.sh"
    # [[ -f ${KAFKA_HOME}/bin/kafka-console-consumer.sh ]] || lsd-mod.log.fail "File does not exists: ${KAFKA_HOME}/bin/kafka-console-consumer.sh"

    ## 1. First, create a topic named TutorialTopic by typing:
    ${KAFKA_HOME}/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 1 --topic TutorialTopic

    ## 2. create a producer - Publish the string "Hello, World" to the TutorialTopic topic by typing:
    echo "Hello, World" | ${KAFKA_HOME}/bin/kafka-console-producer.sh --broker-list localhost:9092 --topic TutorialTopic > /dev/null

    ## 3. create a Kafka consumer - consumes messages from TutorialTopic.
    ## --from-beginning flag, which allows the consumption of messages that were published before the consumer was started
    ## If there are no configuration issues, you should see Hello, World in your terminal:
    ## When you are done testing, press CTRL+C to stop the consumer script. 
    ${KAFKA_HOME}/bin/kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic TutorialTopic --from-beginning

    lsd-mod.log.info "Stopping kafka..."
    __kafka-stop ${KAFKA_HOME}

    return 0
  } || {
    lsd-mod.log.error "Invalid paramerters!"
    return -1
  }
}

kafka-verify.main "$@"
