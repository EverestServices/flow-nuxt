begin;

-- Enable pgcrypto for encode/decode base64 used by blob RPCs
create extension if not exists pgcrypto with schema public;

commit;
