$Time = (Measure-Command {

    1..1E4 | ForEach-Object {

        $_

    }

}).TotalMilliseconds

 [pscustomobject]@{

    Type = 'ForEach-Object'

    Time_ms = $Time

 }

 Clear-Variable $Time


$Time = (Measure-Command {

    ForEach ($i in (1..1E4)) {

        $i

    }

}).TotalMilliseconds

  [pscustomobject]@{

    Type = 'ForEach_Statement'

    Time_ms = $Time

 }