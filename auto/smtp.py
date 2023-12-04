import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from email.mime.image import MIMEImage
import sys

def send_email(smtp_server, smtp_port, smtp_username, smtp_password, sender_email, receiver_email, subject="Vmess", body="None", attachment_path=None):
    if smtp_server == "" or smtp_port == "" or smtp_username == "" \
    or smtp_password == "" or sender_email == "" or receiver_email == "":
        return
    # Build the email
    msg = MIMEMultipart()
    msg['From'] = sender_email
    msg['To'] = receiver_email
    msg['Subject'] = subject

    # Email content
    msg.attach(MIMEText(body, 'plain'))

    # Attach an attachment
    if attachment_path:
        with open(attachment_path, 'rb') as attachment_file:
            attachment = MIMEImage(attachment_file.read())
            msg.attach(attachment)

    # Connect to the SMTP server and send the email
    try:
        server = smtplib.SMTP(smtp_server, smtp_port)
        server.starttls()
        server.login(smtp_username, smtp_password)
        server.sendmail(sender_email, receiver_email, msg.as_string())
        print('Email sent successfully')
    except Exception as e:
        print(f'Email sending failed, error message: {str(e)}')
    finally:
        server.quit()

if __name__ == "__main__":
    if len(sys.argv) < 9:
        print("Please provide enough parameters: smtp_server smtp_port smtp_username smtp_password sender_email receiver_email subject body [attachment_path]")
        sys.exit(1)
    # server info
    smtp_server = sys.argv[1]
    smtp_port = int(sys.argv[2])
    smtp_username = sys.argv[3]
    smtp_password = sys.argv[4]
    # email info
    sender_email = sys.argv[5]
    receiver_email = sys.argv[6]
    subject = sys.argv[7]
    body = sys.argv[8]
    attachment_path = sys.argv[9] if len(sys.argv) > 9 else None

    send_email(smtp_server, smtp_port, smtp_username, smtp_password, sender_email, receiver_email, subject, body, attachment_path)
