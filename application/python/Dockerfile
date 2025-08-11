FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .

# Install New Relic agent
RUN pip install newrelic

EXPOSE 5000

# Start with New Relic
CMD ["newrelic-admin", "run-program", "python", "app.py"]
