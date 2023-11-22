@echo.
@echo.


PowerShell -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""tpm2.ps1""' -Verb RunAs}"


@echo and done!

 pause