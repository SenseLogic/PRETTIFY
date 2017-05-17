<!DOCTYPE html><html lang="<?php echo "fr"; ?>"><head>
<form>blabla<textarea id="text">blabla<span>blabla</span></textarea>blabla</form>
<!-- long comment -->

<!-- 
    long comment
-->

<style type="text/css">
/*
    long comment
*/

body {
color:purple;/* long comment */
background-color:#d8da3d;}

ul {
color:red;
background-color:url("media/bg.jpg");/* long comment */
}
</style>

<!--=end of line
/*
    long comment
*/

body {
color:purple;/* long comment */
background-color:#d8da3d;}

ul {
color:red;
background-color:url("media/bg.jpg");/* long comment */
}
=-->

<script type="text/javascript">
// short comment

var t=new Array('A',"'B'\"",'"C" \'');// short comment

/*
    long comment
*/

for (var i=1;i<20;++i)
{
for (var j=1;
j- 1<i+1;
j++)
{
var x=-(i+j)>0||i<-j?i*2:j- 1;
var a=i+j;
var b=i- j;

if (i<j||i==-1)
{
continue;
}
else if (i<j
|| (i==-1
&& j>=0))
{
continue;
}
else
{
break;
}
}
}

$( "ul.first" )
.find( ".foo" )
.css( "background-color", "red" )
.end()
.find( ".bar" )
.css( "background-color", "green" )
.end();

$("#p1").css("color", "red")
.slideUp(2000)
.slideDown(2000);

$(document).ready(
function(){
$("#p1").mouseenter(
function(){
alert("You entered p1!");
});
});

$("input")
.focus(
function(){
$(this).css("background-color", "#cccccc");
})
.blur(
function(){
$(this).css("background-color", "#ffffff");
});
</script>
</head>
<body>
<p>text 1</p><p>text 2</p>
<font size="2" face="Arial">Le texte en HTML</font>
<?php
// short comment

$requete
    ="SELECT *"
      . " FROM table"
      . " WHERE x = 'xyz'";

$requete2
    =foo(
         func(
             bar("SELECT *"
. " FROM table"
. " WHERE x = 'xyz'")
)
);
$heure=date("H\hi");
print("<font size=\"2\" face=\"Arial\"> et celui en PHP.</font>");
?>

<!-- long comment -->

<br/><font size="2" face="Arial">Il est <?php echo $heure; ?>.
</font>
<br/>
<div>
</div><span>
<?php
/*
    long comment
*/

public function x()
{
$foo='test';
$bar=1;

return $foo->func($bar);
}
?>
</span>blabla<span>blabla</span>blabla<span>blabla</span>blabla

<?php
require_once 'connexion.php';

/*
    REQUETES
*/

$requete
    = "SELECT id, titre
FROM rubriques
ORDER BY tri ASC;";

$resultats = $connexion->query( $requete );
$rubriques_menu = $resultats->fetchAll( PDO::FETCH_OBJ );    /* long comment */
$resultats->closeCursor();
$resultats = null;
?>

<ul class="nav nav-pills">
<?php foreach( $rubriques_menu as $rubrique_menu ) { ?>
<li<?php if ( $rubrique_menu->id == $id ) echo ' class="active"' ?>>
<a href="index.php?id=<?php echo $rubrique_menu->id; ?>">
<?php echo $rubrique_menu->titre; ?>
</a>
</li>
<?php } ?>
</ul></body></html>

<?xml version="1.0"?>
<!DOCTYPE student [
<!--'student' must contain three
    child elements in the order listed-->
<!ELEMENT
student (id,surname,firstname)
>
<!--the elements listed below may
    only contain text that is not markup-->
<!ELEMENT id (#PCDATA)>
<!ELEMENT firstname (#PCDATA)>
<!ELEMENT surname (#PCDATA)>
]>
<student>
<id>9216735</id>
<surname>Smith</surname>
<firstname>
Jo
Wilfried
</firstname>
</student>
