BUILD=build
OBJECTS=$(BUILD)/boot.o

.PHONY: clean all

all: $(BUILD)/boot.bin

$(BUILD)/boot.bin: $(BUILD) $(OBJECTS)
	@echo "Building FreePaw bootloader"
	@ld $(OBJECTS) -o $(BUILD)/boot.bin -T architecture/x86/link.ld
	@echo "Built bootloader: $@"

$(BUILD)/%.o: architecture/x86/bootsector.asm
	@as $< -o $@

$(BUILD):
	@echo "Creating build dir: $(BUILD)"
	@mkdir -p $(BUILD)

clean:
	@echo "Removing build dir: $(BUILD)"
	@rm -rf $(BUILD)
