-- Migration: Create contracts table
-- Description: Structure definition for contracts
-- Dependencies: 421_create_scenarios_table.sql

CREATE TABLE IF NOT EXISTS "public"."contracts" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "survey_id" "uuid",
    "client_name" character varying(255),
    "client_address" character varying(500),
    "client_phone" character varying(50),
    "client_email" character varying(255),
    "birth_place" character varying(255),
    "date_of_birth" "date",
    "id_card_number" character varying(50),
    "tax_id" character varying(50),
    "mother_birth_name" character varying(255),
    "bank_account_number" character varying(100),
    "citizenship" character varying(100),
    "marital_status" character varying(50),
    "residence_card_number" character varying(50),
    "mailing_address" character varying(500),
    "name" character varying(255) DEFAULT 'Contract 1'::character varying NOT NULL,
    "scenario_id" "uuid",
    "contract_mode" character varying(20) DEFAULT 'offer'::character varying NOT NULL,
    "status" character varying(20) DEFAULT 'draft'::character varying NOT NULL,
    "commission_rate" numeric(5,4) DEFAULT 0.12 NOT NULL,
    "vat" integer DEFAULT 27 NOT NULL,
    "total_price" numeric(12,2) DEFAULT 0,
    "roof_configuration" "jsonb",
    "notes" "text",
    "first_sent_at" timestamp with time zone,
    "first_signed_at" timestamp with time zone,
    CONSTRAINT "contracts_contract_mode_check" CHECK ((("contract_mode")::"text" = ANY ((ARRAY['offer'::character varying, 'contract'::character varying])::"text"[]))),
    CONSTRAINT "contracts_status_check" CHECK ((("status")::"text" = ANY ((ARRAY['draft'::character varying, 'sent'::character varying, 'accepted'::character varying, 'rejected'::character varying])::"text"[]))),
    CONSTRAINT "contracts_vat_check" CHECK (("vat" = ANY (ARRAY[0, 5, 12, 15, 21, 27])))
);

-- Add constraints
ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_scenario_id_fkey FOREIGN KEY (scenario_id) REFERENCES public.scenarios(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_survey_id_fkey FOREIGN KEY (survey_id) REFERENCES public.surveys(id) ON DELETE SET NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_contracts_contract_mode ON public.contracts USING btree (contract_mode);
CREATE INDEX IF NOT EXISTS idx_contracts_first_sent_at ON public.contracts USING btree (first_sent_at);
CREATE INDEX IF NOT EXISTS idx_contracts_first_signed_at ON public.contracts USING btree (first_signed_at);
CREATE INDEX IF NOT EXISTS idx_contracts_scenario_id ON public.contracts USING btree (scenario_id);
CREATE INDEX IF NOT EXISTS idx_contracts_status ON public.contracts USING btree (status);
CREATE INDEX IF NOT EXISTS idx_contracts_survey_id ON public.contracts USING btree (survey_id);

-- Set table owner
ALTER TABLE public.contracts OWNER TO postgres;
