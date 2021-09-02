ARG PYTHON_VERSION=3.9

FROM python:${PYTHON_VERSION}

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY working .

WORKDIR /working/srcpy/

CMD ["python","main.py"]