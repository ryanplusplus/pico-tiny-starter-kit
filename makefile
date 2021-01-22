export GNUMAKEFLAGS := --no-print-directory
CMAKE := cmake --build build

.PHONY: all
all: build/Makefile
	@+$(CMAKE)

build/Makefile:
	@+cmake -B build .

.PHONY: clean
clean:
	@rm -rf build

%:
	@+$(CMAKE) --target $@
