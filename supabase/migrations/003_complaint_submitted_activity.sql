-- New complaint feed row (client inserts are blocked by RLS; use trigger like status/comments).
ALTER TABLE complaint_activities DROP CONSTRAINT IF EXISTS complaint_activities_type_check;
ALTER TABLE complaint_activities ADD CONSTRAINT complaint_activities_type_check
  CHECK (type IN ('status_changed', 'comment_added', 'complaint_submitted'));

CREATE OR REPLACE FUNCTION log_complaint_submitted()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO complaint_activities
    (complaint_id, complaint_title, user_id, type, message)
  VALUES
    (NEW.id,
     NEW.title,
     NEW.user_id,
     'complaint_submitted',
     'Your complaint was submitted.');
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_complaint_submitted ON complaints;
CREATE TRIGGER on_complaint_submitted
  AFTER INSERT ON complaints
  FOR EACH ROW
  EXECUTE FUNCTION log_complaint_submitted();
