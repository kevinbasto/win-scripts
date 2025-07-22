param(
    [Parameter(Mandatory=$true)]
    [string]$path,

    [Parameter(Mandatory=$true)]
    [string]$name
)

ng g c $path/$name --standalone=false
ng g s $path/$name/$name