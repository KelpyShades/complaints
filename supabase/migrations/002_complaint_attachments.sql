-- Complaint media attachments (v1: audio only) + private storage bucket policies.
-- Object path layout: {complaint_id}/{random}.{ext} (first segment must match complaint id).
-- Policies use DROP IF EXISTS so this file can be re-run safely in the SQL editor.

CREATE TABLE IF NOT EXISTS public.complaint_attachments (
  id                uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  complaint_id      uuid NOT NULL REFERENCES public.complaints (id) ON DELETE CASCADE,
  user_id           uuid NOT NULL REFERENCES public.profiles (id),
  type              text NOT NULL CHECK (type IN ('audio', 'image', 'document')),
  storage_path      text NOT NULL,
  mime_type         text NOT NULL,
  file_size         bigint NOT NULL CHECK (file_size > 0),
  duration_seconds  integer,
  created_at        timestamptz NOT NULL DEFAULT now()
);

CREATE UNIQUE INDEX IF NOT EXISTS complaint_attachments_one_audio_per_complaint
  ON public.complaint_attachments (complaint_id)
  WHERE type = 'audio';

CREATE INDEX IF NOT EXISTS idx_complaint_attachments_complaint_id
  ON public.complaint_attachments (complaint_id);

ALTER TABLE public.complaint_attachments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "complaint_attachments_select_owner_or_admin" ON public.complaint_attachments;
CREATE POLICY "complaint_attachments_select_owner_or_admin"
  ON public.complaint_attachments
  FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1
      FROM public.complaints c
      WHERE c.id = complaint_attachments.complaint_id
        AND (
          c.user_id = auth.uid()
          OR EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
          )
        )
    )
  );

DROP POLICY IF EXISTS "complaint_attachments_insert_owner" ON public.complaint_attachments;
CREATE POLICY "complaint_attachments_insert_owner"
  ON public.complaint_attachments
  FOR INSERT
  TO authenticated
  WITH CHECK (
    auth.uid() = user_id
    AND EXISTS (
      SELECT 1 FROM public.complaints c
      WHERE c.id = complaint_attachments.complaint_id
        AND c.user_id = auth.uid()
    )
  );

INSERT INTO storage.buckets (id, name, public)
VALUES ('complaint-media', 'complaint-media', false)
ON CONFLICT (id) DO NOTHING;

DROP POLICY IF EXISTS "complaint_media_insert_owner" ON storage.objects;
CREATE POLICY "complaint_media_insert_owner"
  ON storage.objects
  FOR INSERT
  TO authenticated
  WITH CHECK (
    bucket_id = 'complaint-media'
    AND EXISTS (
      SELECT 1 FROM public.complaints c
      WHERE c.id::text = (storage.foldername(name))[1]
        AND c.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "complaint_media_select_owner_or_admin" ON storage.objects;
CREATE POLICY "complaint_media_select_owner_or_admin"
  ON storage.objects
  FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'complaint-media'
    AND EXISTS (
      SELECT 1 FROM public.complaints c
      WHERE c.id::text = (storage.foldername(name))[1]
        AND (
          c.user_id = auth.uid()
          OR EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND p.role = 'admin'
          )
        )
    )
  );

DROP POLICY IF EXISTS "complaint_media_delete_owner" ON storage.objects;
CREATE POLICY "complaint_media_delete_owner"
  ON storage.objects
  FOR DELETE
  TO authenticated
  USING (
    bucket_id = 'complaint-media'
    AND EXISTS (
      SELECT 1 FROM public.complaints c
      WHERE c.id::text = (storage.foldername(name))[1]
        AND c.user_id = auth.uid()
    )
  );
