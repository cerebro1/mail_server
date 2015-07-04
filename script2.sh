echo "<!DOCTYPE html>
<head>

<title><roundcube:object name="pagetitle" /></title>
<meta name="Robots" content="noindex,nofollow" />
<roundcube:include file="/includes/links.html" />
</head>
<body>
<script type="text/javascript">
function register()
{
document.getElementById("register").style.visibility = "visible";
document.getElementById("login-form").style.visibility = "hidden";

}
function fpass()
{
document.getElementById("fpass").style.visibility = "visible";
document.getElementById("login-form").style.visibility = "hidden";

}
function mail()
{
var str=document.myForm.email.value;
if(str.search("@$dom")==-1)
{
document.getElementById("domainchk").style.visibility = "visible";
}
else
{
document.getElementById("domainchk").style.visibility = "hidden";
}
}

function validate()
{
if(document.myForm.password.value==document.myForm.repassword.value)
{
return true;
}
else
{
alert("password is incorrect.");
return false;
}
}
</script>
<roundcube:object name="logo" src="/images/roundcube_logo.png" id="logo" border="0" style="margin:0 11px" />

<roundcube:object name="message" id="message" />

<div id="login-form" style="visibility:visible">
<div class="boxtitle"><roundcube:label name="welcome" /></div>
<div class="boxcontent">
<form name="form" action="./"method="post" >
<roundcube:object name="loginform" form="form" />
<p style="text-align:center;"><input type="submit" class="button mainaction" value="<roundcube:label name='login' />" /></p>
</form>
<hr>
If not registered
<input type="submit" onclick="register()" name="register" value="CLICK HERE" />
<br>
Forgot Password ? <input type="submit" onclick="fpass()" name="fpass" value="Forgot Password" />

</div>
</div>
<style>
div{text-align:center;color:#0000FF;}
</style>

<div class "boxtitle" id="register" style="visibility:hidden; border: 2px solid rgb(100, 149, 237); color:#23238e; background-color:white; position:absolute; top:100px; left:470px; width:410px; height:390px;">
<div class="boxtitle"><roundcube:label name="welcome" /></div>
<div class="boxcontent">

<form method="post" action="../index.php" id= "register" name="myForm"  >

                        <p class="contact"><label for="email">UserName</label></p>
                        <input id="email" name="email"  required type="email">
         (@$dom)
<div id="domainchk" style ="visibility:hidden; color:red">
         <p>
Choose a new username (which will also be your new kiet.edu address)
</p></div>
                        <p class="contact"><label for="password">Create a password</label></p>
                        <input type="password"  name="password" required="" type="text" onkeypress="mail()">
                        <p class="contact"><label for="repassword">Confirm your password</label></p>
                        <input type="password"  name="repassword" required="" type="text">
      <p class="contact"><label for="question">select your Question</label></p>
<select name="ques">
  <option value="What is your first pet name?">What is your first pet name?</option>
  <option value="What is your favourite sport?">What is your favourite sport?</option>
  <option value="What is your favourite movie?">What is your favourite movie?</option>
  <option value="What is your favourite birth place?">What is your favourite birth place?</option>
</select>
 <p class="contact"><label for="answer">Enter your answer</label></p>
                        <input id="ans" name="ans"  required type="text">

<input type ="submit" onclick = "validate()" value="Register">
</form>
</div >
</div>
<div class "boxtitle" id="fpass" style="visibility:hidden; border: 2px solid rgb(100, 149, 237); color:#23238e; background-color:white; position:absolute; top:100px;left:470px; width:410px; height:390px;">

<div class="boxtitle"><roundcube:label name="welcome" /></div>
<div class="boxcontent">
<form method="post"action="../fpass.php" id= "fpass" name="myF"  >
 <p class="contact"><label for="email">UserName</label></p>
                        <input id="email" name="email"  required type="email">

 <p class="contact"><label for="question">select your Question</label></p>
<select name="ques">
<option value="What is your first pet name?">What is your first pet name?</option>
  <option value="What is your favourite sport?">What is your favourite sport?</option>
  <option value="What is your favourite movie?">What is your favourite movie?</option>
  <option value="What is your favourite birth place?">What is your favourite birth place?</option>

</select>
 <p class="contact"><label for="answer">Enter your answer</label></p>
                        <input id="ans" name="ans"  required type="text">
<p class="contact"><label for="answer">New password</label></p>
                        <input id="ans" name="newpass"  required type="password">

           <input type ="submit"  value="Change Password">
</form>
</div>
</div>
<roundcube:object name="preloader" images="
    /images/icons/folders.png
    /images/mail_footer.png
    /images/taskicons.gif
    /images/display/loading.gif
    /images/pagenav.gif
    /images/mail_toolbar.png
    /images/searchfield.gif
    /images/messageicons.png
    /images/icons/reset.gif
    /images/abook_toolbar.png
    /images/icons/groupactions.png
    /images/watermark.gif
" />
</body>
</html>" > /usr/share/roundcube/skins/default/templates/login.html
cp fpass.php /var/www/fpass/php
echo '<!DOCTYPE html>
<html>
<body>


<?php
//echo "Hello World!";
$dbhost = '127.0.0.1:3306';
$dbuser = 'root';
$dbpass = 'root';
$conn = mysql_connect($dbhost, $dbuser, $dbpass);
if(! $conn )
{
  die('Could not connect: ' . mysql_error());
}

$password = addslashes($_POST['password']);
$email =  addslashes($_POST['email']);
$ques = addslashes($_POST['ques']);
$ans = addslashes($_POST['ans']);

$sql= "INSERT INTO virtual_users ( password,email,question,answer) VALUES (MD5('$password'), '$email','$ques','$ans')";

mysql_select_db('mailserver');

$retval = mysql_query( $sql, $conn );

if(! $retval )
{
  die('Could not enter data: ' . mysql_error());
}

mysql_close($conn)
?>
<h1 align="center">Registered Successfully</h1>
<form action="../roundcube">
<style="align:center;"><input type="submit" value=" Login "/>
</form>
</body>
</html> '>/var/pass/index.php
