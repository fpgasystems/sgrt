# Makefile

# Compiler
CC = gcc

# Compiler flags
CFLAGS = -Wall

# Source files (relative to the project root directory)
SRC = src/main.c src/onic.c

# Include directories (relative to the project root directory)
INCLUDES = -I./src

# Target executable (placed in the project root directory)
TARGET = onic

# Build target
$(TARGET): $(SRC)
	$(CC) $(CFLAGS) $(INCLUDES) -o $(TARGET) $(SRC)

# Clean target
clean:
	rm -f $(TARGET)
