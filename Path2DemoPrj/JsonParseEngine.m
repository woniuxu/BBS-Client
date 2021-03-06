//
//  JsonParseEngine.m
//  虎踞龙盘BBS
//
//  Created by 张晓波 on 4/28/12.
//  Copyright (c) 2012 Ethan. All rights reserved.
//

#import "JsonParseEngine.h"
#import "WBUtil.h"
@implementation JsonParseEngine

+(User *)parseLogin:(NSDictionary *)loginDictionary
{
    NSString * code = [loginDictionary objectForKey:@"code"];
    if (!code)
    {
        User * myself = [[User alloc] init];
        myself.ID = [loginDictionary objectForKey:@"id"];
        myself.name = [loginDictionary objectForKey:@"user_name"];
        return myself;
    }
    else {
        return nil;
    }
}

+(NSArray *)parseFriends:(NSDictionary *)friendsDictionary
{
    BOOL success = [[friendsDictionary objectForKey:@"success"] boolValue];
    if (success)
    {
        NSMutableArray * friends = [[NSMutableArray alloc] init];
        NSArray * temp = [friendsDictionary objectForKey:@"friends"];
        NSUInteger count = [temp count];
        for (int i=0; i<count; i++) {
            User * user = [[User alloc] init];
            
            NSString * name = [[[friendsDictionary objectForKey:@"friends"] objectAtIndex:i] objectForKey:@"name"];
            NSString * ID = [[[friendsDictionary objectForKey:@"friends"] objectAtIndex:i] objectForKey:@"id"];
            NSString * mode = [[[friendsDictionary objectForKey:@"friends"] objectAtIndex:i] objectForKey:@"mode"];
            
            user.name = name;
            user.ID = ID;
            user.mode = mode;
            
            [friends addObject:user];
        }
        return friends;
    }
    else {
        return nil;
    }
}
+(NSArray *)parseMails:(NSDictionary *)friendsDictionary Type:(int)type
{
    NSString * code = [friendsDictionary objectForKey:@"code"];
    if (!code)
    {
        NSMutableArray * mails = [[NSMutableArray alloc] init];
        NSArray * temp = [friendsDictionary objectForKey:@"mail"];
        NSUInteger count = [temp count];
        for (int i=0; i<count; i++) {
            Mail * mail = [[Mail alloc] init];
            
            mail.ID = [[[[friendsDictionary objectForKey:@"mail"] objectAtIndex:i] objectForKey:@"index"] intValue];
            mail.size = [[[[friendsDictionary objectForKey:@"mail"] objectAtIndex:i] objectForKey:@"size"] intValue];
            mail.unread = ![[[[friendsDictionary objectForKey:@"mail"] objectAtIndex:i] objectForKey:@"is_read"] boolValue];
            
            NSString * author;
            NSObject * authortest = [[[friendsDictionary objectForKey:@"mail"] objectAtIndex:i] objectForKey:@"user"];
            if ([authortest isKindOfClass:[NSDictionary class]]) {
                author = [[[[friendsDictionary objectForKey:@"mail"] objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"];
            }
            else
                author = [[[friendsDictionary objectForKey:@"mail"] objectAtIndex:i] objectForKey:@"user"];
            
            
            mail.author = author;
            mail.title = [[[friendsDictionary objectForKey:@"mail"] objectAtIndex:i] objectForKey:@"title"];
            
            NSTimeInterval interval = [[[[friendsDictionary objectForKey:@"mail"] objectAtIndex:i] objectForKey:@"post_time"] doubleValue];
            mail.time = [NSDate dateWithTimeIntervalSince1970:interval];
            mail.type = type;
            
            [mails addObject:mail];
        }
        return mails;
    }
    else {
        return nil;
    }
}


+(Mail *)parseSingleMail:(NSDictionary *)friendsDictionary  Type:(int)type
{
    NSString * code = [friendsDictionary objectForKey:@"code"];
    if (!code)
    {
        Mail * mail = [[Mail alloc] init];
        
        mail.ID = [[friendsDictionary objectForKey:@"index"] intValue];
        mail.size = [[friendsDictionary objectForKey:@"size"] intValue];
        mail.unread = ![[friendsDictionary objectForKey:@"is_read"] boolValue];
        
        NSString * author;
        NSObject * authortest = [friendsDictionary objectForKey:@"user"];
        if ([authortest isKindOfClass:[NSDictionary class]]) {
            author = [[friendsDictionary objectForKey:@"user"] objectForKey:@"id"];
        }
        else
            author = [friendsDictionary objectForKey:@"user"];
        
        
        mail.author = author;
        mail.title = [friendsDictionary objectForKey:@"title"];
        
        NSTimeInterval interval = [[friendsDictionary objectForKey:@"post_time"] doubleValue];
        mail.time = [NSDate dateWithTimeIntervalSince1970:interval];
        mail.type = type;
        mail.content = [JsonParseEngine trimText:(NSString *)[friendsDictionary objectForKey:@"content"]];

        return mail;
    }
    else {
        return nil;
    }
}

+(NSArray *)parseBoards:(NSDictionary *)boardsDictionary
{
    NSString * code = [boardsDictionary objectForKey:@"code"];
    if (!code)
    {
        NSMutableArray * boards = [[NSMutableArray alloc] init];
        NSArray * temp;
        
        temp = [boardsDictionary objectForKey:@"section"];
        for (int i = 0; i < [temp count]; i++) {
            
            if (![[[boardsDictionary objectForKey:@"section"] objectAtIndex:i] isKindOfClass:[NSDictionary class]])
                continue;   //应对搜索
            
            Board * board = [[Board alloc] init];
            NSString * name = [[[boardsDictionary objectForKey:@"section"] objectAtIndex:i] objectForKey:@"name"];
            int section = [[[[boardsDictionary objectForKey:@"section"] objectAtIndex:i] objectForKey:@"id"] intValue];
            NSString * description = [[[boardsDictionary objectForKey:@"section"] objectAtIndex:i] objectForKey:@"description"];
            int users = [[[[boardsDictionary objectForKey:@"section"] objectAtIndex:i] objectForKey:@"user_online_count"] intValue];
            int count = [[[[boardsDictionary objectForKey:@"section"] objectAtIndex:i] objectForKey:@"post_today_count"] intValue];
            
            board.name = name;
            board.section = section;
            board.leaf = NO;
            board.description = description;
            board.users = users;
            board.count = count;
            
            [boards addObject:board];
        }
        
        temp = [boardsDictionary objectForKey:@"board"];
        for (int i = 0; i < [temp count]; i++) {
            Board * board = [[Board alloc] init];
            
            NSString * name = [[[boardsDictionary objectForKey:@"board"] objectAtIndex:i] objectForKey:@"name"];
            int section = [[[[boardsDictionary objectForKey:@"board"] objectAtIndex:i] objectForKey:@"id"] intValue];
            NSString * description = [[[boardsDictionary objectForKey:@"board"] objectAtIndex:i] objectForKey:@"description"];
            int users = [[[[boardsDictionary objectForKey:@"board"] objectAtIndex:i] objectForKey:@"user_online_count"] intValue];
            int count = [[[[boardsDictionary objectForKey:@"board"] objectAtIndex:i] objectForKey:@"post_today_count"] intValue];
            
            board.name = name;
            board.section = section;
            board.leaf = YES;
            board.description = description;
            board.users = users;
            board.count = count;
            
            [boards addObject:board];
        }
        
        temp = [boardsDictionary objectForKey:@"sub_section"];
        if ([temp count] != 0) {
            for (int j = 0; j < [temp count]; j++) {
                Board * board = [[Board alloc] init];
                board.name = [[boardsDictionary objectForKey:@"sub_section"] objectAtIndex:j];
                board.leaf = NO;
                [boards addObject:board];
            }
        }
        return boards;
    }
    else {
        return nil;
    }
}

+(NSArray *)parseTopics:(NSDictionary *)topicsDictionary
{
    NSMutableArray * topTen = [[NSMutableArray alloc] init];
    NSArray * temp = [topicsDictionary objectForKey:@"article"];
    NSUInteger count = [temp count];
    if (count > 0) {
        topTen = [[NSMutableArray alloc] init];
    }
    
    for (int i=0; i<count; i++) {
        Topic * topic = [[Topic alloc] init];
        
        int ID = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"id"] intValue];
        int gID = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"group_id"] intValue];
        int reID = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"reply_id"] intValue];
        NSString * title = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"title"];
        
        
        NSString * author;
        NSObject * authortest = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"user"];
        if ([authortest isKindOfClass:[NSDictionary class]]) {
            author = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"];
        }
        else
            author = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"user"];

        
        
        NSString * board = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"board_name"];
        
        NSTimeInterval interval = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"post_time"] doubleValue];
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
        
        int replies = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"reply_count"] intValue];
        BOOL unread = ![[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"is_read"] boolValue];
        
        NSString * markString = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"flag"];
        BOOL marked = [markString isEqualToString:@""] ? NO : YES;
        BOOL top = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"is_top"] boolValue];
        BOOL has_attachment = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"has_attachment"] boolValue];
        
        int index = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"index"] intValue];
        topic.unread = unread;
        topic.ID = ID;
        topic.gID = gID;
        topic.reid = reID;
        topic.title = title;
        topic.author = author;
        topic.board = board;
        topic.time = time;
        topic.replies = replies;
        topic.mark = marked;
        topic.top = top;
        topic.hasAtt = has_attachment;
        topic.index = index;
        [topTen addObject:topic];
    }
    return topTen;
}

+(NSArray *)parseSearchTopics:(NSDictionary *)topicsDictionary
{
    NSMutableArray * topTen = nil;
    NSArray * temp = [topicsDictionary objectForKey:@"threads"];
    NSUInteger count = [temp count];
    if (count > 0) {
        topTen = [[NSMutableArray alloc] init];
    }
    
    for (int i=0; i<count; i++) {
        Topic * topic = [[Topic alloc] init];
        
        int ID = [[[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"id"] intValue];
        NSString * title = [[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"title"];
        
        
        NSString * author;
        NSObject * authortest = [[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"user"];
        if ([authortest isKindOfClass:[NSDictionary class]]) {
            author = [[[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"];
        }
        else
            author = [[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"user"];
        
        NSString * board = [[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"board_name"];
        
        NSTimeInterval interval = [[[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"post_time"] doubleValue];
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
        
        int replies = [[[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"reply_count"] intValue];
        BOOL unread = [[[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"unread"]boolValue];
        NSString * markString = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"flag"];
        BOOL marked = [markString isEqualToString:@""] ? NO : YES;
        BOOL top = [[[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"is_top"] boolValue];
        
        BOOL has_attachment = [[[[topicsDictionary objectForKey:@"threads"] objectAtIndex:i] objectForKey:@"has_attachment"] boolValue];
        
        
        topic.unread = unread;
        topic.ID = ID;
        topic.title = title;
        topic.author = author;
        topic.board = board;
        topic.time = time;
        topic.replies = replies;
        topic.mark = marked;
        topic.top = top;
        topic.hasAtt = has_attachment;
        
        [topTen addObject:topic];
    }
    return topTen;
}
+(NSArray *)parseReplyTopic:(NSDictionary *)topicsDictionary
{
    NSString * code = [topicsDictionary objectForKey:@"code"];
    if (!code)
    {
        Topic * topic = [[Topic alloc] init];
        
        int ID = [[topicsDictionary objectForKey:@"id"] intValue];
        int gID = [[topicsDictionary objectForKey:@"group_id"] intValue];
        int reid = [[topicsDictionary objectForKey:@"reply_id"] intValue];
        
        NSString * title = [topicsDictionary objectForKey:@"title"];
        NSString * content = [topicsDictionary objectForKey:@"content"];
        
        NSString * author;
        NSURL *authFaceURL;
        NSObject * authortest = [topicsDictionary objectForKey:@"user"];
        if ([authortest isKindOfClass:[NSDictionary class]]) {
            author = [[topicsDictionary objectForKey:@"user"] objectForKey:@"id"];
            authFaceURL = [NSURL URLWithString:[[topicsDictionary objectForKey:@"user"] objectForKey:@"face_url"]];
        }
        else
            author = [topicsDictionary objectForKey:@"user"];

        NSString * board = [topicsDictionary objectForKey:@"board_name"];
        
        NSTimeInterval interval = [[topicsDictionary objectForKey:@"post_time"] doubleValue];
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
        
        NSString * quote = [topicsDictionary objectForKey:@"quote"];
        NSString * quoter = [topicsDictionary objectForKey:@"quoter"];
        
        NSMutableArray * attArray=[[NSMutableArray alloc] init];
        NSDictionary * attDic= [topicsDictionary objectForKey:@"attachment"];
        NSArray * temp2 = [attDic objectForKey:@"file"];
        NSUInteger count2 = [temp2 count];
        for (int j=0; j < count2; j++) {
            Attachment *attElement=[[Attachment alloc]init];
            [attElement setAttFileName:[[temp2 objectAtIndex:j] objectForKey:@"name"]];
            [attElement setAttSize:[[[temp2 objectAtIndex:j] objectForKey:@"size"] intValue]];
            
            NSMutableString * urlString = [[[temp2 objectAtIndex:j] objectForKey:@"url"] mutableCopy];
            [urlString replaceCharactersInRange:NSMakeRange(0, 28) withString:@"http://bbs.byr.cn/att"];
            [attElement setAttUrl:urlString];
            
            [attArray addObject:attElement];
        }
        
        topic.attachments = attArray;
        topic.ID = ID;
        topic.gID = gID;
        topic.reid = reid;
        topic.title = title;
        topic.content = [JsonParseEngine trimText:content];
        topic.author = author;
        topic.authorFaceURL = authFaceURL;
        topic.board = board;
        topic.time = time;
        
        if ([quote length] > 12) {
            topic.quote = [quote substringToIndex:12];
        }
        else {
            topic.quote = quote;
        }
        
        topic.quoter =quoter;
        return [NSArray arrayWithObject:topic];

    }
    return nil;
}

+ (NSString *)trimText:(NSString *)originalText
{
    NSString *oldText = [originalText stringByReplacingOccurrencesOfString:@"\n--\n\n" withString:@""];
    NSString *oldText1 = [oldText stringByReplacingOccurrencesOfString:@"\n--\n" withString:@""];
    NSString *oldText2 = [oldText1 stringByReplacingOccurrencesOfString:@"\n--" withString:@""];
    NSError *error = nil;
    
    //NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[.*?[^]]\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\[[^em].*?[^]]\\]" options:NSRegularExpressionCaseInsensitive error:&error];
    NSString *text = [regex stringByReplacingMatchesInString:oldText2 options:0 range:NSMakeRange(0, oldText2.length) withTemplate:@""];

    return text;
}

+(NSArray *)parseSingleTopic:(NSDictionary *)topicsDictionary
{
    NSMutableArray * topTen;
    NSArray * temp = [topicsDictionary objectForKey:@"article"];
    NSUInteger count = [temp count];
    if (count > 0) {
        topTen = [[NSMutableArray alloc] init];
    }
    else
        return nil;

    for (int i=0; i<count; i++) {
        Topic * topic = [[Topic alloc] init];
        
        int ID = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"id"] intValue];
        int gID = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"group_id"] intValue];
        int reid = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"reply_id"] intValue];
        
        NSString * title = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"title"];
        NSString * content = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"content"];
        
        NSString * author;
        NSURL *authFaceURL;
        NSObject * authortest = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"user"];
        if ([authortest isKindOfClass:[NSDictionary class]]) {
            author = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"user"] objectForKey:@"id"];
            authFaceURL = [NSURL URLWithString:[[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"user"] objectForKey:@"face_url"]];
        }
        else
            author = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"user"];
        
        NSString * board = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"board_name"];
        
        NSTimeInterval interval = [[[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"post_time"] doubleValue];
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
        
        NSString * quote = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"quote"];
        NSString * quoter = [[[topicsDictionary objectForKey:@"article"] objectAtIndex:i] objectForKey:@"quoter"];

        NSMutableArray * attArray=[[NSMutableArray alloc] init];
        NSDictionary * attDic=[[[topicsDictionary objectForKey:@"article"] objectAtIndex: i] objectForKey:@"attachment"];
        NSArray * temp2 = [attDic objectForKey:@"file"];
        NSUInteger count2 = [temp2 count];
        for (int j=0; j < count2; j++) {
            Attachment *attElement=[[Attachment alloc]init];
            [attElement setAttFileName:[[temp2 objectAtIndex:j] objectForKey:@"name"]];
            [attElement setAttSize:[[[temp2 objectAtIndex:j] objectForKey:@"size"] intValue]];
            
            NSMutableString * urlString = [[[temp2 objectAtIndex:j] objectForKey:@"url"] mutableCopy];
            [urlString replaceCharactersInRange:NSMakeRange(0, 28) withString:@"http://bbs.byr.cn/att"];
            [attElement setAttUrl:urlString];
            
            [attArray addObject:attElement];
        }
        
        topic.attachments = attArray;
        topic.ID = ID;
        topic.gID = gID;
        topic.reid = reid;
        topic.title = title;
        topic.content = [JsonParseEngine trimText:content];
        topic.author = author;
        topic.authorFaceURL = authFaceURL;
        topic.board = board;
        topic.time = time;
        
        if ([quote length] > 12) {
            topic.quote = [quote substringToIndex:12];
        }
        else {
            topic.quote = quote;
        }
        
        topic.quoter =quoter;
        [topTen addObject:topic];
    }
    return topTen;
}


+(User *)parseUserInfo:(NSDictionary *)loginDictionary
{
    NSString * code = [loginDictionary objectForKey:@"code"];
    if (!code)
    {
        User * user = [[User alloc] init];
        user.ID = [loginDictionary objectForKey:@"id"];
        user.name = [loginDictionary objectForKey:@"user_name"];
        NSString * avatarString = [loginDictionary objectForKey:@"face_url"];
        if ([avatarString hasSuffix:@".png"] || [avatarString hasSuffix:@".jpeg"] || [avatarString hasSuffix:@".jpg"] || [avatarString hasSuffix:@".tiff"] || [avatarString hasSuffix:@".bmp"])
        {
            user.avatar = [NSURL URLWithString:[loginDictionary objectForKey:@"face_url"]];
        }
        else {
            user.avatar = nil;
        }

        
        NSTimeInterval interval = [[loginDictionary objectForKey:@"last_login_time"] doubleValue];
        NSDate *time = [NSDate dateWithTimeIntervalSince1970:interval];
        
        user.lastlogin = time;
        user.level = [loginDictionary objectForKey:@"level"];
        user.posts = [[loginDictionary objectForKey:@"post_count"] intValue];
        user.perform = [[loginDictionary objectForKey:@"stay_count"] intValue];
        user.experience = [[loginDictionary objectForKey:@"stay_count"] intValue];
        user.medals = [[loginDictionary objectForKey:@"score"] intValue];
        user.logins = [[loginDictionary objectForKey:@"login_count"] intValue];
        user.life = [[loginDictionary objectForKey:@"life"] intValue];
        
        user.gender = [loginDictionary objectForKey:@"gender"];
        user.astro = [loginDictionary objectForKey:@"astro"];
        user.mode = [loginDictionary objectForKey:@"mode"];
        user.isOnline = [[loginDictionary objectForKey:@"is_online"] boolValue];
        return user;
    }
    else {
        return nil;
    }
}

+(NSArray *)parseAttachments:(NSDictionary *)attDic
{
    NSString * code = [attDic objectForKey:@"code"];
    if (!code)
    {
        NSMutableArray *attArray = [[NSMutableArray alloc] init];
        NSArray * temp = [attDic objectForKey:@"file"];
        NSUInteger count = [temp count];
        for (int j=0;  j<count;j++) {
            Attachment *attElement=[[Attachment alloc]init];
            [attElement setAttFileName:[[[attDic objectForKey:@"file"] objectAtIndex:j] objectForKey:@"name"]];
            NSMutableString * urlString = [[[[attDic objectForKey:@"file"] objectAtIndex:j] objectForKey:@"url"] mutableCopy];
            if (urlString.length >= 28) {
                [urlString replaceCharactersInRange:NSMakeRange(0, 28) withString:@"http://bbs.byr.cn/att"];
            }
            
            [attArray addObject:attElement];
        }
        return attArray;
    }
    else {
        return nil;
    }
}

+(NSArray *)parseVoteList:(NSDictionary *)votesDictionary
{
    NSString * code = [votesDictionary objectForKey:@"code"];
    if (!code)
    {
        NSMutableArray *votesArray = [[NSMutableArray alloc] init];
        NSArray * temp = [votesDictionary objectForKey:@"votes"];
        NSUInteger count = [temp count];
        for (int j=0;  j<count;j++) {
            Vote *vote = [[Vote alloc]init];
            
            vote.vid = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"vid"] intValue];
            vote.voteTitle = [[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"title"];
            
            NSTimeInterval interval = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"start"] intValue];
            NSDate *start = [NSDate dateWithTimeIntervalSince1970:interval];
            
            interval = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"end"] intValue];
            NSDate *end = [NSDate dateWithTimeIntervalSince1970:interval];
            
            vote.start = start;
            vote.end = end;
            
            vote.user_count = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"user_count"] intValue];
            vote.vote_count = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"vote_count"] intValue];
            vote.type = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"type"] intValue];
            vote.limit = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"limit"] intValue];
            
            
            vote.is_end = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"is_end"] boolValue];
            vote.is_deleted = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"is_deleted"] boolValue];
            vote.is_result_voted = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"is_result_voted"] boolValue];
            
            
            NSObject * authortest = [[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"user"];
            NSString *author = NULL;
            NSURL *authorHeadUrl = NULL;
            
            if ([authortest isKindOfClass:[NSDictionary class]]) {
                author = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"user"] objectForKey:@"id"];
                authorHeadUrl = [NSURL URLWithString:[[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"user"] objectForKey:@"face_url"]];
            }
            else {
                author = [[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"user"];
                authorHeadUrl = nil;
            }
            
            vote.author = author;
            vote.authorHeadUrl = authorHeadUrl;
            
            NSMutableArray *voted = [[NSMutableArray alloc] init];
            NSObject * votedtest = [[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"voted"];
            if ([votedtest isKindOfClass:[NSDictionary class]]) {
                NSArray *myVotes = [[[[votesDictionary objectForKey:@"votes"] objectAtIndex:j] objectForKey:@"voted"] objectForKey:@"viid"];
                [voted addObjectsFromArray:myVotes];
            }
            else
                voted = nil;
            
            vote.voted = voted;
            [votesArray addObject:vote];
        }
        return votesArray;
    }
    else {
        return nil;
    }
}

+(Vote *)parseSingleVote:(NSDictionary *)voteDictionary
{
    NSString * code = [voteDictionary objectForKey:@"code"];
    if (!code)
    {
        Vote *vote = [[Vote alloc]init];
        
        vote.vid = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"vid"] intValue];
        vote.voteTitle = [[voteDictionary objectForKey:@"vote"] objectForKey:@"title"];
        
        NSTimeInterval interval = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"start"] intValue];
        NSDate *start = [NSDate dateWithTimeIntervalSince1970:interval];
        
        interval = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"end"] intValue];
        NSDate *end = [NSDate dateWithTimeIntervalSince1970:interval];
        
        vote.start = start;
        vote.end = end;
        
        vote.user_count = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"user_count"] intValue];
        vote.vote_count = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"vote_count"] intValue];
        vote.type = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"type"] intValue];
        vote.limit = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"limit"] intValue];
        
        
        vote.is_end = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"is_end"] boolValue];
        vote.is_deleted = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"is_deleted"] boolValue];
        vote.is_result_voted = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"is_result_voted"] boolValue];
        
        
        NSObject * authortest = [[voteDictionary objectForKey:@"vote"] objectForKey:@"user"];
        NSString *author = NULL;
        NSURL *authorHeadUrl = NULL;
        
        if ([authortest isKindOfClass:[NSDictionary class]]) {
            author = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"user"] objectForKey:@"id"];
            authorHeadUrl = [NSURL URLWithString:[[[voteDictionary objectForKey:@"vote"] objectForKey:@"user"] objectForKey:@"face_url"]];
        }
        else {
            author = [[voteDictionary objectForKey:@"vote"] objectForKey:@"user"];
            authorHeadUrl = nil;
        }
        
        vote.author = author;
        vote.authorHeadUrl = authorHeadUrl;
        
        NSMutableArray *voted = [[NSMutableArray alloc] init];
        NSObject * votedtest = [[voteDictionary objectForKey:@"vote"] objectForKey:@"voted"];
        if ([votedtest isKindOfClass:[NSDictionary class]]) {
            NSArray *myVotes = [[[voteDictionary objectForKey:@"vote"] objectForKey:@"voted"] objectForKey:@"viid"];
            [voted addObjectsFromArray:myVotes];
        }
        else {
            voted = nil;
        }
        vote.voted = voted;
        
        
        NSArray *options = [[voteDictionary objectForKey:@"vote"] objectForKey:@"options"];
        NSMutableArray *optionsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < [options count]; i++) {
            Vote *option = [[Vote alloc] init];
            option.viid = [[[options objectAtIndex:i] objectForKey:@"viid"] intValue];
            option.num = [[[options objectAtIndex:i] objectForKey:@"num"] intValue];
            option.label = [[options objectAtIndex:i] objectForKey:@"label"];
            [optionsArray addObject:option];
        }
        vote.options = optionsArray;
        
        return vote;
    }
    else {
        return nil;
    }

}
@end


