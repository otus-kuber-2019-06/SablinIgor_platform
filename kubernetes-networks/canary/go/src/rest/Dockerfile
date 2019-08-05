# Start from the latest golang base image
FROM golang:latest as builder

# Add Maintainer Info
LABEL maintainer="Sablin Igor <sablin.igor@gmail.com>"

# Set the Current Working Directory inside the container
WORKDIR /app

# Download all dependencies
RUN go get github.com/joho/godotenv
RUN go get github.com/gorilla/mux

COPY . .

# Build the Go app
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o rest .

######## Start a new stage from scratch #######
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /app/rest .

# Expose port 8000 to the outside world
EXPOSE 8000

# Command to run the executable
CMD ["./rest"] 
