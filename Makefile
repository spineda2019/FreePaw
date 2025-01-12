BUILD=build
OBJECTS=$(BUILD)/boot.o

.PHONY: clean all floppy

all: $(BUILD)/boot.bin

$(BUILD)/boot.bin: $(BUILD) $(OBJECTS)
	@echo "Building FreePaw bootloader..."
	@ld $(OBJECTS) -o $(BUILD)/boot.bin -T architecture/x86/link.ld
	@echo "Built bootloader: $@"

$(BUILD)/%.o: architecture/x86/bootsector.asm
	@as $< -o $@

$(BUILD):
	@echo "Creating build dir: $(BUILD)..."
	@mkdir -p $(BUILD)
	@echo "Finished creating build directory"

floppy: $(BUILD)/FreePaw.img

$(BUILD)/FreePaw.img: $(BUILD)/boot.bin
	@echo "Writing bootloader to floopy image..."
	@bximage -q -func=create -fd=1.44M $(BUILD)/FreePaw.img
	@dd if=$< of=$@ bs=512 count=1
	@echo "Finished writing to floppy"

clean:
	@echo "Removing build dir: $(BUILD)..."
	@rm -rf $(BUILD)
	@echo "Finished clean"
