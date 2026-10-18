PINZX PROJECT UI update

Updated primary app flow:
- Intro screen uses assets/videos/pinzx_intro.mp4 supplied for this update.
- Loading percentage follows the actual video playback position.
- SKIP navigates immediately to the vertically scrollable PINZX PROJECT dashboard.
- Natural intro completion displays READY briefly, then opens the dashboard.
- GET STARTED NOW on the dashboard continues to /login.
- Login screen branding and layout refreshed; invalid credentials show LOGIN GAGAL with the Indonesian message and an OK button that dismisses only the dialog.
- Startup no longer waits indefinitely for remote config before showing the bundled intro.

The existing project directories and feature modules were preserved. This update focuses on the intro/dashboard/login flow; the login API/backend integration is not redesigned here.
