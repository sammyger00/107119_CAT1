<?php

namespace App\Services;

use Exception;
use AfricasTalking\SDK\AfricasTalking;

class AfricasTalkingService
{
    protected $at;
    protected $sms;
    protected $email;

    public function __construct()
    {
        $username = config('services.africastalking.username');
        $apiKey = config('services.africastalking.key');

        $this->at = new AfricasTalking($username, $apiKey);
        $this->sms = $this->at->sms();
        $this->email = $this->at->email();
    }

    public function sendSms($to, $message)
    {
        try {
            $result = $this->sms->send([
                'to' => $to,
                'message' => $message,
                'from' => config('services.africastalking.from'),
            ]);
            return $result;
        } catch (Exception $e) {
            return ['status' => 'error', 'message' => $e->getMessage()];
        }
    }

    public function sendEmail($to, $subject, $message, $attachments = [])
    {
        try {
            $emailData = [
                'to' => $to,
                'subject' => $subject,
                'message' => $message,
            ];

            if (!empty($attachments)) {
                $emailData['attachments'] = $attachments;
            }

            $result = $this->email->send($emailData);
            return $result;
        } catch (Exception $e) {
            return ['status' => 'error', 'message' => $e->getMessage()];
        }
    }
}
