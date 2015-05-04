#if TARGET_OS_IPHONE

#define TRVSColor UIColor
#define TRVSImage UIImage
#define TRVSFont UIFont
#define TRVSBezierPath UIBezierPath

#elif TARGET_OS_MAC && !TARGET_OS_IPHONE

#define TRVSColor NSColor
#define TRVSImage NSImage
#define TRVSFont NSFont
#define TRVSBezierPath NSBezierPath

#endif
