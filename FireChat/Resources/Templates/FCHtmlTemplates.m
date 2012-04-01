//
//  FCHtmlTemplates.m
//  FireChat
//
//  Created by Terry Worona on 12-03-31.
//  Copyright (c) 2012 FireChat. All rights reserved.
//

#import "FCHtmlTemplates.h"

NSString * const kFCHtmlChatTemplate = @"<html>\
<head>\
<title>Chat Example</title>\
<script type=\"text/javascript\" src=\"http://static.firebase.com/v0/firebase.js\"></script>\
<script type=\"text/javascript\" src=\"http://ajax.googleapis.com/ajax/libs/jquery/1.7.1/jquery.min.js\"></script>\
</head>\
<body>\
<script type=\"text/javascript\">\
var chatMessagesPath = new Firebase(\'http://gamma.firebase.com/%@\');\
$(document).ready(function () {\
	chatMessagesPath.on(\'child_added\', function(childSnapshot) {\
		var message = childSnapshot.val();\
		window.location = \"http://new-msg.com/\" + message.name + \"/\" + message.text + \"/\" + childSnapshot.name();\
	});\
});\
function send_message(a, b){\
	chatMessagesPath.push({\
	name:a,\
	text:b\
	});\
}\
</script>\
</body>\
</html>";
