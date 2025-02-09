name=gubbles
godot=godot

all: windows linux zip

clean:
	rm -rf build

linux:
	mkdir -p build/linux
	$(godot) -v --export-release --headless "Linux" ../build/linux/$(name).x86_64 project/project.godot

windows:
	mkdir -p build/windows
	$(godot) -v --export-release --headless "Windows Desktop" ../build/windows/$(name).exe project/project.godot

zip: windows linux
	mkdir -p build/zip
	mkdir -p build/zip/source
	rsync -av --progress project build/zip/source --exclude .godot
	echo "This project was built using [Godot Engine](https://godotengine.org) 4.3." > build/zip/source/README.md
	mkdir -p build/zip/release/linux
	mkdir -p build/zip/release/windows
	echo "Executables are provided for Microsoft Windows Desktop and Linux." > build/zip/release/README.md
	cp -r build/windows/* build/zip/release/windows
	cp -r build/linux/* build/zip/release/linux
	cp LICENSE build/zip
	mkdir -p build/zip/press
	cp -r press/* build/zip/press
	cd build/zip;	zip $(name)-src.zip -r .
	cd build; zip executables.zip -r windows linux
