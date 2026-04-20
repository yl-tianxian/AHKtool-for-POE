; 请将 :: 前替换为实际需要使用的热键
#HotIf WinActive("ahk_exe PathOfExile.exe")  ; 使用进程名匹配
`::
{
    Send "{1}"
    Send "{3}"
    Send "{4}"
    Send "{5}"
}
#HotIf  ; 结束条件区域