FROM python:3.12-slim

WORKDIR /app

# Install dependencies
COPY server/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy server application
COPY server/ server/

# Environment and port
ENV PORT=8765
EXPOSE 8765

CMD ["python", "server/server.py"]
