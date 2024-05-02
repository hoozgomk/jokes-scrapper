FROM python:3.11-alpine

WORKDIR /

COPY requirements.txt requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

COPY app app

ENV PYTHONPATH "${PYTHONPATH}:./app"

EXPOSE 8000

#CMD ["python", "app/main.py"]
CMD ["python", "app/app_working.py"]