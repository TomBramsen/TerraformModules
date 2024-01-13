
Copy code
# Install Chocolatey package manager
iwr https://chocolatey.org/install.ps1 -UseBasicParsing | iex

# Install Parsec client
choco install parsec-client

# Install DirectX
choco install directx

# Install VC Runtime
choco install vcredist-all

# Install .NET Framework
choco install netfx-4.8-devpack
#Bemærk, at scriptet starter med at installere Chocolatey, som er en pakke manager til Windows. Det giver dig mulighed for at installere Parsec-klienten, DirectX, VC Runtime og .NET Framework ved hjælp af kommandoerne "choco install".
