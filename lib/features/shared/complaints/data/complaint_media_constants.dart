/// Supabase Storage bucket for complaint attachments (see migration 002).
const String kComplaintMediaBucketId = 'complaint-media';

/// Reject uploads larger than this (bytes) before hitting the network.
const int kComplaintAudioMaxBytes = 20 * 1024 * 1024;

/// Reject image uploads larger than this (10MB).
const int kComplaintImageMaxBytes = 10 * 1024 * 1024;

/// Maximum number of images a student can attach.
const int kComplaintMaxImages = 5;
