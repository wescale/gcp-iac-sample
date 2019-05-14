FROM python:3.8.0a4-alpine3.9

WORKDIR /usr/src/app

COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

ENV MYSQL_HOST localhost
ENV MYSQL_PORT 3306
ENV MYSQL_USER user1
ENV MYSQL_PASSWORD password

ENV CREATE_DATABASE test
ENV CREATE_USER test
ENV CREATE_PASSWORD test


COPY . .

CMD [ "python", "./main.py" ]