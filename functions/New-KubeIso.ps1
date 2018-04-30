function New-KubeIso {
  [CmdletBinding()]
  param (
    [String]$SourceFolder,
    [String]$OutPath
  )
  $fsi = New-Object -ComObject IMAPI2FS.MsftFileSystemImage
  $fsi.FileSystemsToCreate = 3
  $fsi.VolumeName = "cidata"
  Get-ChildItem $SourceFolder | ForEach-Object {
    $fsi.Root.AddTree($_.FullName, $false)
  }
  ($cp = New-Object System.CodeDom.Compiler.CompilerParameters).CompilerOptions = '/unsafe'
  if (!('ISOFile' -as [type])) {
    Add-Type -CompilerParameters $cp -TypeDefinition @"
public class ISOFile
{ 
  public unsafe static void Create(string Path, object Stream, int BlockSize, int TotalBlocks)
  {
    int bytes = 0;
    byte[] buf = new byte[BlockSize];
    var ptr = (System.IntPtr)(&bytes);
    var o = System.IO.File.OpenWrite(Path);
    var i = Stream as System.Runtime.InteropServices.ComTypes.IStream;
    if (o != null) {
      while (TotalBlocks-- > 0) {
        i.Read(buf, BlockSize, ptr); o.Write(buf, 0, bytes);
      }
      o.Flush(); o.Close();
    }
  }
}
"@
  }
  $image = $fsi.CreateResultImage()
  [ISOFile]::Create($OutPath, $image.ImageStream, $image.BlockSize, $image.TotalBlocks)
}