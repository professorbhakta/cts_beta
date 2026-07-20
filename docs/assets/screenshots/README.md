# Screenshot assets

Add **PNG** screenshots here for documentation.

Category folders (ready for files):

- `auth/` · `admin/` · `driver/` · `commuter/` · `shared/` · `offline/`

Filenames: see [SCREENSHOTS.md](../../SCREENSHOTS.md).

## How to capture

1. Run debug app on emulator or device: `flutter run`
2. Navigate to each screen in [SCREENSHOTS.md](../SCREENSHOTS.md) checklist
3. Save as PNG with the filenames listed there
4. Optional: same device width (e.g. 1080×2400 phone) for consistent docs

## Android emulator

- ... menu → **Screenshot**  
- Or `adb exec-out screencap -p > screen.png`

## iOS Simulator

- File → Save Screen

## Do not commit

- Real user phone numbers or passwords visible in screenshots
- Production API keys in debug overlays

When this folder contains images, update the user guides in `docs/guides/` to embed them.
