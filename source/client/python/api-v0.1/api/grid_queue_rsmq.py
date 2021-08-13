import rsmq
from botocore.exceptions import ClientError
import json
import logging
from utils import grid_error_logger as errlog

logging.basicConfig(format="%(asctime)s - %(levelname)s - %(filename)s - %(funcName)s  - %(lineno)d - %(message)s",
                    datefmt='%H:%M:%S', level=logging.INFO)


class QueueRSMQ:


    def __init__(self, endpoint_url, queue_name, region):
        # Connection + Authentication

        logging.info("Initializing QueueRSMQ: {} {} {}".format(
            endpoint_url, queue_name, region)
            )

        # Accept endpoint_url with the following format:
        # http://host:port
        if '//' in endpoint_url:
            endpoint_url = endpoint_url.split("//")[-1]

        [self.host, self.port] = endpoint_url.split(":")

        self.queue_name = queue_name

        try:

            self.queue = rsmq.RedisSMQ(host=self.host, port=self.port, qname=queue_name)
            self.queue.createQueue(vt=40, delay=0).execute()

        except rsmq.cmd.exceptions.QueueAlreadyExists:
            pass
        except Exception as e:
            errlog.log("QueueSQS: cannot connect to queue_name [{}], endpoint_url [{}] region [{}] : {}".format(
                queue_name, endpoint_url, region, e))
            raise e

    def send_message(self, message_body):
        response = self.queue.sendMessage(message=message_body).execute()
        return response

    # Single write &  Batch write
    def send_messages(self, message_bodies=[]):
        responses = {
            'Successful': [],
            'Failed': [],
        }

        for body in message_bodies:
            try:
                id = self.queue.send_message(body)
                responses['Successful'].append(id)
            except Exception:
                responses['Failed'].append(id)
        return responses

        # return {
        #     'Successful': [
        #         {
        #             'Id': str,
        #         }
        #     ],
        #     'Failed': [
        #         {
        #             'Id': str,
        #         }
        #     ]
        # }

    def receive_message(self, wait_time_sec=0):

        messages = self.receiveMessage(quiet=True).exceptions(False).execute()

        if not messages:
            # No messages were returned
            return {}

        return {
                "body": json.loads(messages['message'])['MessageBody'],
                "properties": {
                    "message_handle_id": messages['id'],
                }
            }

    def delete_message(self, message_handle_id, task_priority=None):
        """Deletes message from the queue by the message_handle_id.
        Often this function is called when message is sucessfully consumed.

        Args:
        message_handle_id(str): the sqs handler associated of the message to be deleted
        task_priority(int): <Interface argument, not used in this class>

        Returns: None

        Raises: ClientError: if message can not be deleted
        """

        try:
            self.queue.deleteMessage(id=message_handle_id).execute()

        except rsmq.cmd.exceptions.RedisSMQException as e:
            errlog.log("Cannot delete message {} : {}".format(message, e))
            raise e

        return None

    def change_visibility(self, message_handle_id, visibility_timeout_sec, task_priority=None):
        """Changes visibility timeout of the message by its handle

        Args:
        message_handle_id(str): the sqs handler associated of the message to be deleted
        task_priority(int): <Interface argument, not used in this class>

        Returns: None

        Raises: ClientError: on failure
        """

        try:
            self.queue.changeMessageVisibility(
                vt=visibility_timeout_sec,
                id=message_handle_id,
            ).execute()

        except rsmq.cmd.exceptions.RedisSMQException as e:
            errlog.log("Cannot reset VTO for message {} : {}".format(message_handle_id, e))
            raise e


        return None


    def get_queue_length(self):
        queue_length = int(self.queue.getQueueAttributes()['msgs'])
        # print(f"Number of messages in the queue {queue_length}")
        return queue_length