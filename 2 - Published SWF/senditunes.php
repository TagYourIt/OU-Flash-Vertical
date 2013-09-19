<?php
if(!empty($_REQUEST['sender_mail']) && (!empty($_REQUEST['itunesurl'])))
{
    $to = $_REQUEST['sender_mail'];; // replace with your mail address
    $s_name = "Name";
    $s_mail = "mukesh.wani@gmail.com";
    $subject = "Requested iTunesU course from OU";
    $body = stripslashes($_REQUEST['itunesurl']);
    $body .= "\n\n---------------------------\n";
    $body .= "Mail sent by: $s_name <$s_mail>\n";
    $header = "From: $s_name <$s_mail>\n";
    $header .= "Reply-To: $s_name <$s_mail>\n";
    $header .= "X-Mailer: PHP/" . phpversion() . "\n";
    $header .= "X-Priority: 1";
    if(@mail($to, $subject, $body, $header))
    {
        echo "output=sent";
    } else {
        echo "output=error";
    }
} else {
    echo "output=error";
}
?>