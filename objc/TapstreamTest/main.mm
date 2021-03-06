#import <stdio.h>
#import <js/jsapi.h>
#import "TSEvent.h"
#import "TSOperationQueue.h"
#import "TSTapstream.h"
#import "TSEvent.h"

#import <v8.h>
using namespace v8;


// Used for testing purposes to convince the v8 garbage collector to run frequently
#define TEST_GC 0

#if TEST_GC
#define FAKE_OBJECT_SIZE 1024
#define EXTERNAL_ALLOC(x) printf("Allocation adjust: %+d...", (x)); V8::AdjustAmountOfExternalAllocatedMemory(1024*1024*(x)); printf(" done\n");
#else
#define EXTERNAL_ALLOC(x)
#define FAKE_OBJECT_SIZE
#endif


Handle<Value> OperationQueue_expect(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	Handle<Object> self = args.This();
	TSOperationQueue *q = (BRIDGE TSOperationQueue *)(Handle<External>::Cast(self->GetInternalField(0))->Value());

	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsString()) return ThrowException(String::New("Arg 0 must be a string"));
	String::Utf8Value name(args[0]);

	[q expect:[NSString stringWithUTF8String:*name]];
	return Undefined();
}
void OperationQueue_destructor(Persistent<Value> object, void *parameters)
{
	#if TEST_GC
	printf("OperationQueue destructor\n");
	#endif
	Locker locker;

	TSOperationQueue *q = (BRIDGE_TRANSFER TSOperationQueue *)(Handle<External>::Cast(object->ToObject()->GetInternalField(0))->Value());
	object->ToObject()->SetInternalField(0, Null());
	object.Dispose();
	object.Clear();

	EXTERNAL_ALLOC(-FAKE_OBJECT_SIZE);
}

Handle<Value> Tapstream_fireEvent(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	Handle<Object> self = args.This();
	TSTapstream *ts = (BRIDGE TSTapstream *)(Handle<External>::Cast(self->GetInternalField(0))->Value());

	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsObject()) return ThrowException(String::New("Arg 0 must be an object"));
	TSEvent *e = (BRIDGE TSEvent *)(Handle<External>::Cast(args[0]->ToObject()->GetInternalField(0))->Value());

	[ts fireEvent:e];
	return Undefined();
}
Handle<Value> Tapstream_fireHit(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	Handle<Object> self = args.This();
	TSTapstream *ts = (BRIDGE TSTapstream *)(Handle<External>::Cast(self->GetInternalField(0))->Value());

	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsObject()) return ThrowException(String::New("Arg 0 must be an object"));
	TSHit *h = (BRIDGE TSHit *)(Handle<External>::Cast(args[0]->ToObject()->GetInternalField(0))->Value());

	[ts fireHit:h completion:nil];
	return Undefined();
}
void Tapstream_destructor(Persistent<Value> object, void *parameters)
{
	#if TEST_GC
	printf("Tapstream destructor\n");
	#endif
	Locker locker;

	TSTapstream *ts = (BRIDGE_TRANSFER TSTapstream *)(Handle<External>::Cast(object->ToObject()->GetInternalField(0))->Value());
	object->ToObject()->SetInternalField(0, Null());
	object.Dispose();
	object.Clear();

	EXTERNAL_ALLOC(-FAKE_OBJECT_SIZE);
}



Handle<Value> Event_addPair(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	Handle<Object> self = args.This();
	TSEvent *event = (BRIDGE TSEvent *)(Handle<External>::Cast(self->GetInternalField(0))->Value());

	if(args.Length() < 2) return ThrowException(String::New("Expected 2 arguments"));

	if(!args[0]->IsString()) return ThrowException(String::New("Arg 0 must be a string"));
	String::Utf8Value key(args[0]);

	if(args[1]->IsString())
	{
		String::Utf8Value value(args[1]);
		[event addValue:[NSString stringWithUTF8String:*value] forKey:[NSString stringWithUTF8String:*key]];
		return Undefined();
	}
	else if(args[1]->IsInt32())
	{
		[event addIntegerValue:args[1]->Int32Value() forKey:[NSString stringWithUTF8String:*key]];
		return Undefined();
	}
	else if(args[1]->IsUint32())
	{
		[event addUnsignedIntegerValue:args[1]->Uint32Value() forKey:[NSString stringWithUTF8String:*key]];
		return Undefined();
	}
	else if(args[1]->IsNumber())
	{
		[event addDoubleValue:args[1]->NumberValue() forKey:[NSString stringWithUTF8String:*key]];
		return Undefined();
	}
	else if(args[1]->IsBoolean())
	{
		[event addBooleanValue:args[1]->BooleanValue() forKey:[NSString stringWithUTF8String:*key]];
		return Undefined();
	}
	
	return ThrowException(String::New("Arg 1 has invalid type"));
}
void Event_destructor(Persistent<Value> object, void *parameters)
{
	#if TEST_GC
	printf("Event destructor\n");
	#endif
	Locker locker;

	TSEvent *event = (BRIDGE_TRANSFER TSEvent *)(Handle<External>::Cast(object->ToObject()->GetInternalField(0))->Value());
	object->ToObject()->SetInternalField(0, Null());
	object.Dispose();
	object.Clear();

	EXTERNAL_ALLOC(-FAKE_OBJECT_SIZE);
}
static Handle<Value> Event_accessor(Local<String> name, const AccessorInfo &info)
{
	String::Utf8Value s(name);
	TSEvent *event = (BRIDGE TSEvent *)(Handle<External>::Cast(info.This()->GetInternalField(0))->Value());

	if(strcmp(*s, "postData") == 0)
	{
		return String::New([event.postData UTF8String]);
	}
	else if(strcmp(*s, "name") == 0)
	{
		return String::New([event.name UTF8String]);
	}
	else if(strcmp(*s, "oneTimeOnly") == 0)
	{
		return v8::Boolean::New(event.oneTimeOnly);
	}
	return Null();
}




Handle<Value> Hit_addTag(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	Handle<Object> self = args.This();
	TSHit *hit = (BRIDGE TSHit *)(Handle<External>::Cast(self->GetInternalField(0))->Value());

	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsString()) return ThrowException(String::New("Arg 0 must be a string"));
	String::Utf8Value tag(args[0]);

	[hit addTag:[NSString stringWithUTF8String:*tag]];
	return Undefined();
}
void Hit_destructor(Persistent<Value> object, void *parameters)
{
	#if TEST_GC
	printf("Hit destructor\n");
	#endif
	Locker locker;

	TSHit *hit = (BRIDGE_TRANSFER TSHit *)(Handle<External>::Cast(object->ToObject()->GetInternalField(0))->Value());
	object->ToObject()->SetInternalField(0, Null());
	object.Dispose();
	object.Clear();

	EXTERNAL_ALLOC(-FAKE_OBJECT_SIZE);
}
static Handle<Value> Hit_accessor(Local<String> name, const AccessorInfo &info)
{
	String::Utf8Value s(name);
	TSHit *hit = (BRIDGE TSHit *)(Handle<External>::Cast(info.This()->GetInternalField(0))->Value());

	if(strcmp(*s, "postData") == 0)
	{
		return String::New([hit.postData UTF8String]);
	}
	else if(strcmp(*s, "trackerName") == 0)
	{
		return String::New([hit.trackerName UTF8String]);
	}
	else if(strcmp(*s, "encodedTrackerName") == 0)
	{
		return String::New([hit.encodedTrackerName UTF8String]);
	}
	return Null();
}



Handle<Value> Util_fail(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsString()) return ThrowException(String::New("Arg 0 must be a string"));
	String::Utf8Value message(args[0]);

	printf("%s\n", *message);
	return ThrowException(String::New("Fail"));
}

Handle<Value> Util_assertEqual(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	if(args.Length() < 2) return ThrowException(String::New("Expected 2 arguments"));

	Handle<Value> a(args[0]);
	Handle<Value> b(args[1]);

	if(!a->Equals(b))
	{
		String::Utf8Value descA(a->ToDetailString());
		String::Utf8Value descB(b->ToDetailString());
		NSString *msg = [NSString stringWithFormat:@"Assertion failed.  Expected:<%@> Actual:<%@>",
			[NSString stringWithUTF8String:*descA],
			[NSString stringWithUTF8String:*descB]
		];
		return ThrowException(String::New([msg UTF8String]));
	}
	return Undefined();
}

Handle<Value> Util_assertTrue(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsBoolean()) return ThrowException(String::New("Arg 0 must be a boolean"));
	bool cond = args[0]->BooleanValue();

	if(!cond)
	{
		return ThrowException(String::New("Assertion failed"));
	}
	return Undefined();
}

Handle<Value> Util_log(const Arguments &args)
{
	Locker locker;
	HandleScope scope;
	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsString()) return ThrowException(String::New("Arg 0 must be a string"));
	String::Utf8Value message(args[0]);

	printf("%s\n", *message);
	return Undefined();
}

Handle<Value> Util_getPostData(const Arguments &args)
{
	Locker locker;
	HandleScope scope;

	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsObject()) return ThrowException(String::New("Arg 0 must be an object"));
	TSTapstream *ts = (BRIDGE TSTapstream *)(Handle<External>::Cast(args[0]->ToObject()->GetInternalField(0))->Value());
	
	Handle<String> postData = String::New([[ts getPostData] UTF8String]);

	return scope.Close(postData);
}

Handle<Value> Util_getDelay(const Arguments &args)
{
	Locker locker;
	HandleScope scope;

	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsObject()) return ThrowException(String::New("Arg 0 must be an object"));
	TSTapstream *ts = (BRIDGE TSTapstream *)(Handle<External>::Cast(args[0]->ToObject()->GetInternalField(0))->Value());
	
	Handle<Number> delay = Number::New((double)[ts getDelay]);

	return scope.Close(delay);
}

Handle<Value> Util_getSavedFiredList(const Arguments &args)
{
	Locker locker;
	HandleScope scope;

	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));

	if(!args[0]->IsObject()) return ThrowException(String::New("Arg 0 must be an object"));
	TSTapstream *ts = (BRIDGE TSTapstream *)(Handle<External>::Cast(args[0]->ToObject()->GetInternalField(0))->Value());
	
	NSArray *strings = [ts getSavedFiredList];
	Handle<Array> array = Array::New(strings.count);
	for(int i = 0; i < strings.count; i++)
	{
		array->Set(Number::New(i), String::New([[strings objectAtIndex:i] UTF8String]));
	}
	return scope.Close(array);
}

Handle<Value> Util_setResponseStatus(const Arguments &args)
{
	Locker locker;
	HandleScope scope;

	if(args.Length() < 2) return ThrowException(String::New("Expected 2 arguments"));

	if(!args[0]->IsObject()) return ThrowException(String::New("Arg 0 must be an object"));
	TSTapstream *ts = (BRIDGE TSTapstream *)(Handle<External>::Cast(args[0]->ToObject()->GetInternalField(0))->Value());

	if(!args[1]->IsInt32()) return ThrowException(String::New("Arg 1 must be an integer"));
	int status = args[1]->ToInt32()->Value();
	
	[ts setResponseStatus:status];
	return Undefined();
}

Handle<Value> Util_newOperationQueue(const Arguments &args)
{
	Locker locker;
	HandleScope scope;

	TSOperationQueue *q = AUTORELEASE([[TSOperationQueue alloc] init]);
	void *ptr = (BRIDGE_RETAINED void *)RETAIN(q);

	Handle<ObjectTemplate> templ = ObjectTemplate::New();
	templ->SetInternalFieldCount(1);
	templ->Set(String::New("expect"), FunctionTemplate::New(InvocationCallback(OperationQueue_expect))->GetFunction(), ReadOnly);
	
	Persistent<Object> obj = Persistent<Object>::New(templ->NewInstance());
	obj.MakeWeak(NULL, OperationQueue_destructor);
	obj->SetInternalField(0, External::New(ptr));

	EXTERNAL_ALLOC(FAKE_OBJECT_SIZE);

	return scope.Close(obj);
}

Handle<Value> Util_newTapstream(const Arguments &args)
{
	Locker locker;
	HandleScope scope;

	if(args.Length() < 4) return ThrowException(String::New("Expected 4 arguments"));

	if(!args[0]->IsObject()) return ThrowException(String::New("Arg 0 must be an object"));
	TSOperationQueue *queue = (BRIDGE TSOperationQueue *)(Handle<External>::Cast(args[0]->ToObject()->GetInternalField(0))->Value());

	if(!args[1]->IsString()) return ThrowException(String::New("Arg 1 must be a string"));
	String::Utf8Value accountName(args[1]);

	if(!args[2]->IsString()) return ThrowException(String::New("Arg 2 must be a string"));
	String::Utf8Value developerSecret(args[2]);

	if(!args[3]->IsString()) return ThrowException(String::New("Arg 3 must be a string"));
	String::Utf8Value hardware(args[3]);

	TSTapstream *ts = AUTORELEASE([[TSTapstream alloc] initWithOperationQueue:queue
		accountName:[NSString stringWithUTF8String:*accountName]
		developerSecret:[NSString stringWithUTF8String:*developerSecret]
		hardware:[NSString stringWithUTF8String:*hardware]
		]);
	void *ptr = (BRIDGE_RETAINED void *)RETAIN(ts);

	Handle<ObjectTemplate> templ = ObjectTemplate::New();
	templ->SetInternalFieldCount(1);
	templ->Set(String::New("fireEvent"), FunctionTemplate::New(InvocationCallback(Tapstream_fireEvent))->GetFunction(), ReadOnly);
	templ->Set(String::New("fireHit"), FunctionTemplate::New(InvocationCallback(Tapstream_fireHit))->GetFunction(), ReadOnly);

	Persistent<Object> obj = Persistent<Object>::New(templ->NewInstance());
	obj.MakeWeak(NULL, Tapstream_destructor);
	obj->SetInternalField(0, External::New(ptr));

	EXTERNAL_ALLOC(FAKE_OBJECT_SIZE);

	return scope.Close(obj);
}

Handle<Value> Util_newEvent(const Arguments &args)
{
	Locker locker;
	HandleScope scope;

	if(args.Length() < 2) return ThrowException(String::New("Expected 2 arguments"));
	
	if(!args[0]->IsString()) return ThrowException(String::New("Arg 0 must be a string"));
	String::Utf8Value name(args[0]);

	if(!args[1]->IsBoolean()) return ThrowException(String::New("Arg 1 must be a boolean"));
	bool oneTimeOnly = args[1]->BooleanValue();

	TSEvent *event = [TSEvent eventWithName:[NSString stringWithUTF8String:*name] oneTimeOnly:oneTimeOnly];
	void *ptr = (BRIDGE_RETAINED void *)RETAIN(event);

	Handle<ObjectTemplate> templ = ObjectTemplate::New();
	templ->SetInternalFieldCount(1);
	templ->SetAccessor(String::New("postData"), Event_accessor);
	templ->SetAccessor(String::New("name"), Event_accessor);
	templ->SetAccessor(String::New("oneTimeOnly"), Event_accessor);
	templ->Set(String::New("addPair"), FunctionTemplate::New(InvocationCallback(Event_addPair))->GetFunction(), ReadOnly);

	Persistent<Object> obj = Persistent<Object>::New(templ->NewInstance());
	obj.MakeWeak(NULL, Event_destructor);
	obj->SetInternalField(0, External::New(ptr));

	EXTERNAL_ALLOC(FAKE_OBJECT_SIZE);

	return scope.Close(obj);
}

Handle<Value> Util_newHit(const Arguments &args)
{
	Locker locker;
	HandleScope scope;

	if(args.Length() < 1) return ThrowException(String::New("Expected 1 argument"));
	
	if(!args[0]->IsString()) return ThrowException(String::New("Arg 0 must be a string"));
	String::Utf8Value name(args[0]);

	TSHit *hit = [TSHit hitWithTrackerName:[NSString stringWithUTF8String:*name]];
	void *ptr = (BRIDGE_RETAINED void *)RETAIN(hit);

	Handle<ObjectTemplate> templ = ObjectTemplate::New();
	templ->SetInternalFieldCount(1);
	templ->SetAccessor(String::New("postData"), Hit_accessor);
	templ->SetAccessor(String::New("trackerName"), Hit_accessor);
	templ->SetAccessor(String::New("encodedTrackerName"), Hit_accessor);
	templ->Set(String::New("addTag"), FunctionTemplate::New(InvocationCallback(Hit_addTag))->GetFunction(), ReadOnly);

	Persistent<Object> obj = Persistent<Object>::New(templ->NewInstance());
	obj.MakeWeak(NULL, Hit_destructor);
	obj->SetInternalField(0, External::New(ptr));

	EXTERNAL_ALLOC(FAKE_OBJECT_SIZE);

	return scope.Close(obj);
}




int main(int argc, char *argv[])
{
	printf("objc_arc = %d\n", __has_feature(objc_arc));
	
	if(argc != 2)
	{
		printf("Call with script argument, eg:  ./TapstreamTest tests.js\n");
		return 0;
	}

	int retVal = 0;

	#if !__has_feature(objc_arc)
	@autoreleasepool {
	#endif

	// Load the script
	NSString *filePath = [NSString stringWithUTF8String:argv[1]];
	NSError *error = nil;
	NSString *fileText = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:&error];
	if(error != nil)
	{
		NSLog(@"Failed to load script: %@", [error localizedDescription]);
		return 1;
	}


	// Startup v8
	{
		Locker locker;
		HandleScope handleScope;

		Handle<ObjectTemplate> globalTemplate = ObjectTemplate::New();

		// Set the language
		globalTemplate->Set(String::New("language"), String::New("objc"), ReadOnly);

		Handle<Context> context = Context::New(NULL, globalTemplate);
		Context::Scope scope(context);

		// Create the global util object and expose it's methods
		Handle<ObjectTemplate> templ = ObjectTemplate::New();
		templ->Set(String::New("fail"), FunctionTemplate::New(InvocationCallback(Util_fail))->GetFunction(), ReadOnly);
		templ->Set(String::New("assertEqual"), FunctionTemplate::New(InvocationCallback(Util_assertEqual))->GetFunction(), ReadOnly);
		templ->Set(String::New("assertTrue"), FunctionTemplate::New(InvocationCallback(Util_assertTrue))->GetFunction(), ReadOnly);
		templ->Set(String::New("log"), FunctionTemplate::New(InvocationCallback(Util_log))->GetFunction(), ReadOnly);
		templ->Set(String::New("getPostData"), FunctionTemplate::New(InvocationCallback(Util_getPostData))->GetFunction(), ReadOnly);
		templ->Set(String::New("getDelay"), FunctionTemplate::New(InvocationCallback(Util_getDelay))->GetFunction(), ReadOnly);
		templ->Set(String::New("getSavedFiredList"), FunctionTemplate::New(InvocationCallback(Util_getSavedFiredList))->GetFunction(), ReadOnly);
		templ->Set(String::New("setResponseStatus"), FunctionTemplate::New(InvocationCallback(Util_setResponseStatus))->GetFunction(), ReadOnly);
		templ->Set(String::New("newOperationQueue"), FunctionTemplate::New(InvocationCallback(Util_newOperationQueue))->GetFunction(), ReadOnly);
		templ->Set(String::New("newTapstream"), FunctionTemplate::New(InvocationCallback(Util_newTapstream))->GetFunction(), ReadOnly);
		templ->Set(String::New("newEvent"), FunctionTemplate::New(InvocationCallback(Util_newEvent))->GetFunction(), ReadOnly);
		templ->Set(String::New("newHit"), FunctionTemplate::New(InvocationCallback(Util_newHit))->GetFunction(), ReadOnly);
		Handle<Object> util = templ->NewInstance();
		context->Global()->Set(String::New("util"), util, ReadOnly);

		TryCatch tryCatch;
		Handle<String> source = String::New([fileText UTF8String], [fileText length]);
		Handle<Script> script = Script::Compile(source, String::New(argv[1]));

		Handle<Value> result = script->Run();
		if(result.IsEmpty())
		{
			String::Utf8Value exception(tryCatch.Exception());
			Handle<Message> message = tryCatch.Message();

			if(message.IsEmpty())
			{
				NSLog(@"%s", *exception);
				retVal = 1;
			}
			else
			{
				String::Utf8Value resource(message->GetScriptResourceName());
				NSLog(@"%s:%d: %s", *resource, message->GetLineNumber(), *exception);
				retVal = 1;
			}
		}

		#if TEST_GC
		// Hacks to wait for the garbage collector to run
		while(!V8::IdleNotification()) {};
		#endif
	}


	#if !__has_feature(objc_arc)
	}
	#endif

	return retVal;
}