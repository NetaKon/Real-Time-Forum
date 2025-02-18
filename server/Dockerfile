# Use the official Python image
FROM python:3.13.2

# Set the working directory
WORKDIR /server

# Copy the requirements file and install dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application files
COPY . .

# Expose port 5000
EXPOSE 5000

# Command to run the Flask app
CMD ["python", "main.py"]