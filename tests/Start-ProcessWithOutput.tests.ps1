Import-Module "$(Split-Path $PSScriptRoot -Parent)\pskubernetes.psd1" -Force
InModuleScope "PSKubernetes" {
  Describe "Start-ProcessWithOutput" {
    It "Throws on non-zero exit codes" {
      { Start-ProcessWithOutput -FilePath "cmd.exe" -Arguments "/c echo stderr 1>&2 && exit 1" } |
        Should -Throw "stderr"
    }
    It "Returns stdout" {
      Start-ProcessWithOutput -FilePath "cmd.exe" -Arguments "/c echo stdout" |
        Should -Match "stdout"
    }
  }
}