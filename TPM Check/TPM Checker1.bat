@echo.
@echo.


PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""tpm.ps1""' -Verb RunAs}"


@echo and done!

 pause