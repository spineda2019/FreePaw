BUILD=build
OBJECTS=$(BUILD)/boot.o

.PHONY: clean all bootloader

all: bootloader

bootloader: $(OBJECTS)
	@echo "Building FreePaw bootloader"
	ld $(OBJECTS) -o $(BUILD)/boot.bin -T architecture/x86/link.ld

$(BUILD)/%.o: architecture/x86/bootsector.asm
	as $< -o $@

$(BUILD):
	@echo "Creating build dir: $(BUILD)"
	@mkdir -p $(BUILD)

clean:
	@echo "Removing build dir: $(BUILD)"
	@rm -rf $(BUILD)
