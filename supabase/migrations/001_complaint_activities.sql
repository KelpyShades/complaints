-- =============================================================================
-- Migration: complaint_activities
-- Creates an activity feed table populated by DB triggers on:
--   1. complaint status changes
--   2. new comment inserts
-- =============================================================================

CREATE TABLE IF NOT EXISTS complaint_activities (
  id            uuid        DEFAULT gen_random_uuid() PRIMARY KEY,
  complaint_id  uuid        REFERENCES complaints(id) ON DELETE CASCADE NOT NULL,
  complaint_title text      NOT NULL,
  user_id       uuid        REFERENCES auth.users(id) ON DELETE CASCADE, -- complaint owner
  type          text        NOT NULL CHECK (type IN ('status_changed', 'comment_added')),
  message       text        NOT NULL,
  read_at       timestamptz,
  created_at    timestamptz DEFAULT now() NOT NULL
);

CREATE INDEX idx_complaint_activities_user_id   ON complaint_activities(user_id);
CREATE INDEX idx_complaint_activities_created_at ON complaint_activities(created_at DESC);

-- ---------------------------------------------------------------------------
-- Trigger 1: log complaint status changes
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION log_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  IF OLD.status IS DISTINCT FROM NEW.status THEN
    INSERT INTO complaint_activities
      (complaint_id, complaint_title, user_id, type, message)
    VALUES
      (NEW.id,
       NEW.title,
       NEW.user_id,
       'status_changed',
       'Status changed to ' || NEW.status);
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_complaint_status_change ON complaints;
CREATE TRIGGER on_complaint_status_change
  AFTER UPDATE ON complaints
  FOR EACH ROW
  EXECUTE FUNCTION log_status_change();

-- ---------------------------------------------------------------------------
-- Trigger 2: log new comments
-- ---------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION log_comment_added()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_title      text;
  v_owner_id   uuid;
BEGIN
  SELECT title, user_id INTO v_title, v_owner_id
    FROM complaints
    WHERE id = NEW.complaint_id;

  INSERT INTO complaint_activities
    (complaint_id, complaint_title, user_id, type, message)
  VALUES
    (NEW.complaint_id,
     v_title,
     v_owner_id,
     'comment_added',
     'A new comment was added');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_comment_added ON complaint_comments;
CREATE TRIGGER on_comment_added
  AFTER INSERT ON complaint_comments
  FOR EACH ROW
  EXECUTE FUNCTION log_comment_added();

-- ---------------------------------------------------------------------------
-- Row-Level Security
-- ---------------------------------------------------------------------------
ALTER TABLE complaint_activities ENABLE ROW LEVEL SECURITY;

-- Students: can only read activities for their own complaints
CREATE POLICY "students_own_activities"
  ON complaint_activities
  FOR SELECT
  USING (user_id = auth.uid());

-- Admins: can read all activities
CREATE POLICY "admins_all_activities"
  ON complaint_activities
  FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = auth.uid() AND role = 'admin'
    )
  );

-- Inserts only allowed via SECURITY DEFINER triggers, not directly
CREATE POLICY "no_direct_insert"
  ON complaint_activities
  FOR INSERT
  WITH CHECK (false);

-- Students/admins can update read_at on their own rows (mark as read)
CREATE POLICY "mark_read"
  ON complaint_activities
  FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());
