--
-- PostgreSQL database dump
--

-- Dumped from database version 15.10 (Debian 15.10-1.pgdg120+1)
-- Dumped by pg_dump version 17.2

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: claim_reason_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.claim_reason_enum AS ENUM (
    'missing_item',
    'wrong_item',
    'production_failure',
    'other'
);


ALTER TYPE public.claim_reason_enum OWNER TO postgres;

--
-- Name: order_claim_type_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_claim_type_enum AS ENUM (
    'refund',
    'replace'
);


ALTER TYPE public.order_claim_type_enum OWNER TO postgres;

--
-- Name: order_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.order_status_enum AS ENUM (
    'pending',
    'completed',
    'draft',
    'archived',
    'canceled',
    'requires_action'
);


ALTER TYPE public.order_status_enum OWNER TO postgres;

--
-- Name: return_status_enum; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE public.return_status_enum AS ENUM (
    'open',
    'requested',
    'received',
    'partially_received',
    'canceled'
);


ALTER TYPE public.return_status_enum OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account_holder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.account_holder (
    id text NOT NULL,
    provider_id text NOT NULL,
    external_id text NOT NULL,
    email text,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.account_holder OWNER TO postgres;

--
-- Name: api_key; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.api_key (
    id text NOT NULL,
    token text NOT NULL,
    salt text NOT NULL,
    redacted text NOT NULL,
    title text NOT NULL,
    type text NOT NULL,
    last_used_at timestamp with time zone,
    created_by text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    revoked_by text,
    revoked_at timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT api_key_type_check CHECK ((type = ANY (ARRAY['publishable'::text, 'secret'::text])))
);


ALTER TABLE public.api_key OWNER TO postgres;

--
-- Name: application_method_buy_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.application_method_buy_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.application_method_buy_rules OWNER TO postgres;

--
-- Name: application_method_target_rules; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.application_method_target_rules (
    application_method_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.application_method_target_rules OWNER TO postgres;

--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.auth_identity (
    id text NOT NULL,
    app_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.auth_identity OWNER TO postgres;

--
-- Name: capture; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.capture (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb
);


ALTER TABLE public.capture OWNER TO postgres;

--
-- Name: cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart (
    id text NOT NULL,
    region_id text,
    customer_id text,
    sales_channel_id text,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone
);


ALTER TABLE public.cart OWNER TO postgres;

--
-- Name: cart_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_address OWNER TO postgres;

--
-- Name: cart_line_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_line_item (
    id text NOT NULL,
    cart_id text NOT NULL,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    quantity integer NOT NULL,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    product_type_id text,
    is_custom_price boolean DEFAULT false NOT NULL,
    CONSTRAINT cart_line_item_unit_price_check CHECK ((unit_price >= (0)::numeric))
);


ALTER TABLE public.cart_line_item OWNER TO postgres;

--
-- Name: cart_line_item_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text,
    CONSTRAINT cart_line_item_adjustment_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.cart_line_item_adjustment OWNER TO postgres;

--
-- Name: cart_line_item_tax_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    item_id text
);


ALTER TABLE public.cart_line_item_tax_line OWNER TO postgres;

--
-- Name: cart_payment_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_payment_collection (
    cart_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_payment_collection OWNER TO postgres;

--
-- Name: cart_promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_promotion (
    cart_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.cart_promotion OWNER TO postgres;

--
-- Name: cart_shipping_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_shipping_method (
    id text NOT NULL,
    cart_id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT cart_shipping_method_check CHECK ((amount >= (0)::numeric))
);


ALTER TABLE public.cart_shipping_method OWNER TO postgres;

--
-- Name: cart_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


ALTER TABLE public.cart_shipping_method_adjustment OWNER TO postgres;

--
-- Name: cart_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cart_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate real NOT NULL,
    provider_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    shipping_method_id text
);


ALTER TABLE public.cart_shipping_method_tax_line OWNER TO postgres;

--
-- Name: currency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.currency (
    code text NOT NULL,
    symbol text NOT NULL,
    symbol_native text NOT NULL,
    decimal_digits integer DEFAULT 0 NOT NULL,
    rounding numeric DEFAULT 0 NOT NULL,
    raw_rounding jsonb NOT NULL,
    name text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.currency OWNER TO postgres;

--
-- Name: customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer (
    id text NOT NULL,
    company_name text,
    first_name text,
    last_name text,
    email text,
    phone text,
    has_account boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.customer OWNER TO postgres;

--
-- Name: customer_account_holder; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_account_holder (
    customer_id character varying(255) NOT NULL,
    account_holder_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_account_holder OWNER TO postgres;

--
-- Name: customer_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_address (
    id text NOT NULL,
    customer_id text NOT NULL,
    address_name text,
    is_default_shipping boolean DEFAULT false NOT NULL,
    is_default_billing boolean DEFAULT false NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_address OWNER TO postgres;

--
-- Name: customer_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_group (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    created_by text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_group OWNER TO postgres;

--
-- Name: customer_group_customer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_group_customer (
    id text NOT NULL,
    customer_id text NOT NULL,
    customer_group_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.customer_group_customer OWNER TO postgres;

--
-- Name: fulfillment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment (
    id text NOT NULL,
    location_id text NOT NULL,
    packed_at timestamp with time zone,
    shipped_at timestamp with time zone,
    delivered_at timestamp with time zone,
    canceled_at timestamp with time zone,
    data jsonb,
    provider_id text,
    shipping_option_id text,
    metadata jsonb,
    delivery_address_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    marked_shipped_by text,
    created_by text,
    requires_shipping boolean DEFAULT true NOT NULL
);


ALTER TABLE public.fulfillment OWNER TO postgres;

--
-- Name: fulfillment_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_address (
    id text NOT NULL,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_address OWNER TO postgres;

--
-- Name: fulfillment_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_item (
    id text NOT NULL,
    title text NOT NULL,
    sku text NOT NULL,
    barcode text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    line_item_id text,
    inventory_item_id text,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_item OWNER TO postgres;

--
-- Name: fulfillment_label; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_label (
    id text NOT NULL,
    tracking_number text NOT NULL,
    tracking_url text NOT NULL,
    label_url text NOT NULL,
    fulfillment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_label OWNER TO postgres;

--
-- Name: fulfillment_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_provider OWNER TO postgres;

--
-- Name: fulfillment_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fulfillment_set (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.fulfillment_set OWNER TO postgres;

--
-- Name: geo_zone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.geo_zone (
    id text NOT NULL,
    type text DEFAULT 'country'::text NOT NULL,
    country_code text NOT NULL,
    province_code text,
    city text,
    service_zone_id text NOT NULL,
    postal_expression jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT geo_zone_type_check CHECK ((type = ANY (ARRAY['country'::text, 'province'::text, 'city'::text, 'zip'::text])))
);


ALTER TABLE public.geo_zone OWNER TO postgres;

--
-- Name: image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image (
    id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    rank integer DEFAULT 0 NOT NULL,
    product_id text NOT NULL
);


ALTER TABLE public.image OWNER TO postgres;

--
-- Name: inventory_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    sku text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    requires_shipping boolean DEFAULT true NOT NULL,
    description text,
    title text,
    thumbnail text,
    metadata jsonb
);


ALTER TABLE public.inventory_item OWNER TO postgres;

--
-- Name: inventory_level; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.inventory_level (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    inventory_item_id text NOT NULL,
    location_id text NOT NULL,
    stocked_quantity numeric DEFAULT 0 NOT NULL,
    reserved_quantity numeric DEFAULT 0 NOT NULL,
    incoming_quantity numeric DEFAULT 0 NOT NULL,
    metadata jsonb,
    raw_stocked_quantity jsonb,
    raw_reserved_quantity jsonb,
    raw_incoming_quantity jsonb
);


ALTER TABLE public.inventory_level OWNER TO postgres;

--
-- Name: invite; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.invite (
    id text NOT NULL,
    email text NOT NULL,
    accepted boolean DEFAULT false NOT NULL,
    token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.invite OWNER TO postgres;

--
-- Name: link_module_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.link_module_migrations (
    id integer NOT NULL,
    table_name character varying(255) NOT NULL,
    link_descriptor jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.link_module_migrations OWNER TO postgres;

--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.link_module_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.link_module_migrations_id_seq OWNER TO postgres;

--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.link_module_migrations_id_seq OWNED BY public.link_module_migrations.id;


--
-- Name: location_fulfillment_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location_fulfillment_provider (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.location_fulfillment_provider OWNER TO postgres;

--
-- Name: location_fulfillment_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.location_fulfillment_set (
    stock_location_id character varying(255) NOT NULL,
    fulfillment_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.location_fulfillment_set OWNER TO postgres;

--
-- Name: mikro_orm_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mikro_orm_migrations (
    id integer NOT NULL,
    name character varying(255),
    executed_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.mikro_orm_migrations OWNER TO postgres;

--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.mikro_orm_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.mikro_orm_migrations_id_seq OWNER TO postgres;

--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.mikro_orm_migrations_id_seq OWNED BY public.mikro_orm_migrations.id;


--
-- Name: notification; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification (
    id text NOT NULL,
    "to" text NOT NULL,
    channel text NOT NULL,
    template text NOT NULL,
    data jsonb,
    trigger_type text,
    resource_id text,
    resource_type text,
    receiver_id text,
    original_notification_id text,
    idempotency_key text,
    external_id text,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'pending'::text NOT NULL,
    CONSTRAINT notification_status_check CHECK ((status = ANY (ARRAY['pending'::text, 'success'::text, 'failure'::text])))
);


ALTER TABLE public.notification OWNER TO postgres;

--
-- Name: notification_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_provider (
    id text NOT NULL,
    handle text NOT NULL,
    name text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    channels text[] DEFAULT '{}'::text[] NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.notification_provider OWNER TO postgres;

--
-- Name: order; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."order" (
    id text NOT NULL,
    region_id text,
    display_id integer,
    customer_id text,
    version integer DEFAULT 1 NOT NULL,
    sales_channel_id text,
    status public.order_status_enum DEFAULT 'pending'::public.order_status_enum NOT NULL,
    is_draft_order boolean DEFAULT false NOT NULL,
    email text,
    currency_code text NOT NULL,
    shipping_address_id text,
    billing_address_id text,
    no_notification boolean,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone
);


ALTER TABLE public."order" OWNER TO postgres;

--
-- Name: order_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_address (
    id text NOT NULL,
    customer_id text,
    company text,
    first_name text,
    last_name text,
    address_1 text,
    address_2 text,
    city text,
    country_code text,
    province text,
    postal_code text,
    phone text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_address OWNER TO postgres;

--
-- Name: order_cart; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_cart (
    order_id character varying(255) NOT NULL,
    cart_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_cart OWNER TO postgres;

--
-- Name: order_change; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_change (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    description text,
    status text DEFAULT 'pending'::text NOT NULL,
    internal_note text,
    created_by text,
    requested_by text,
    requested_at timestamp with time zone,
    confirmed_by text,
    confirmed_at timestamp with time zone,
    declined_by text,
    declined_reason text,
    metadata jsonb,
    declined_at timestamp with time zone,
    canceled_by text,
    canceled_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    change_type text,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text,
    CONSTRAINT order_change_status_check CHECK ((status = ANY (ARRAY['confirmed'::text, 'declined'::text, 'requested'::text, 'pending'::text, 'canceled'::text])))
);


ALTER TABLE public.order_change OWNER TO postgres;

--
-- Name: order_change_action; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_change_action (
    id text NOT NULL,
    order_id text,
    version integer,
    ordering bigint NOT NULL,
    order_change_id text,
    reference text,
    reference_id text,
    action text NOT NULL,
    details jsonb,
    amount numeric,
    raw_amount jsonb,
    internal_note text,
    applied boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_change_action OWNER TO postgres;

--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_change_action_ordering_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_change_action_ordering_seq OWNER TO postgres;

--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_change_action_ordering_seq OWNED BY public.order_change_action.ordering;


--
-- Name: order_claim; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_claim (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    type public.order_claim_type_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.order_claim OWNER TO postgres;

--
-- Name: order_claim_display_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_claim_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_claim_display_id_seq OWNER TO postgres;

--
-- Name: order_claim_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_claim_display_id_seq OWNED BY public.order_claim.display_id;


--
-- Name: order_claim_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_claim_item (
    id text NOT NULL,
    claim_id text NOT NULL,
    item_id text NOT NULL,
    is_additional_item boolean DEFAULT false NOT NULL,
    reason public.claim_reason_enum,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_claim_item OWNER TO postgres;

--
-- Name: order_claim_item_image; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_claim_item_image (
    id text NOT NULL,
    claim_item_id text NOT NULL,
    url text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_claim_item_image OWNER TO postgres;

--
-- Name: order_credit_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_credit_line (
    id text NOT NULL,
    order_id text NOT NULL,
    reference text,
    reference_id text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_credit_line OWNER TO postgres;

--
-- Name: order_display_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_display_id_seq OWNER TO postgres;

--
-- Name: order_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_display_id_seq OWNED BY public."order".display_id;


--
-- Name: order_exchange; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_exchange (
    id text NOT NULL,
    order_id text NOT NULL,
    return_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    no_notification boolean,
    allow_backorder boolean DEFAULT false NOT NULL,
    difference_due numeric,
    raw_difference_due jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    canceled_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.order_exchange OWNER TO postgres;

--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_exchange_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_exchange_display_id_seq OWNER TO postgres;

--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_exchange_display_id_seq OWNED BY public.order_exchange.display_id;


--
-- Name: order_exchange_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_exchange_item (
    id text NOT NULL,
    exchange_id text NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_exchange_item OWNER TO postgres;

--
-- Name: order_fulfillment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_fulfillment (
    order_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_fulfillment OWNER TO postgres;

--
-- Name: order_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_item (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    fulfilled_quantity numeric NOT NULL,
    raw_fulfilled_quantity jsonb NOT NULL,
    shipped_quantity numeric NOT NULL,
    raw_shipped_quantity jsonb NOT NULL,
    return_requested_quantity numeric NOT NULL,
    raw_return_requested_quantity jsonb NOT NULL,
    return_received_quantity numeric NOT NULL,
    raw_return_received_quantity jsonb NOT NULL,
    return_dismissed_quantity numeric NOT NULL,
    raw_return_dismissed_quantity jsonb NOT NULL,
    written_off_quantity numeric NOT NULL,
    raw_written_off_quantity jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    delivered_quantity numeric DEFAULT 0 NOT NULL,
    raw_delivered_quantity jsonb NOT NULL,
    unit_price numeric,
    raw_unit_price jsonb,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb
);


ALTER TABLE public.order_item OWNER TO postgres;

--
-- Name: order_line_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_line_item (
    id text NOT NULL,
    totals_id text,
    title text NOT NULL,
    subtitle text,
    thumbnail text,
    variant_id text,
    product_id text,
    product_title text,
    product_description text,
    product_subtitle text,
    product_type text,
    product_collection text,
    product_handle text,
    variant_sku text,
    variant_barcode text,
    variant_title text,
    variant_option_values jsonb,
    requires_shipping boolean DEFAULT true NOT NULL,
    is_discountable boolean DEFAULT true NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    compare_at_unit_price numeric,
    raw_compare_at_unit_price jsonb,
    unit_price numeric NOT NULL,
    raw_unit_price jsonb NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_price boolean DEFAULT false NOT NULL,
    product_type_id text
);


ALTER TABLE public.order_line_item OWNER TO postgres;

--
-- Name: order_line_item_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_line_item_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_line_item_adjustment OWNER TO postgres;

--
-- Name: order_line_item_tax_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_line_item_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    item_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_line_item_tax_line OWNER TO postgres;

--
-- Name: order_payment_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_payment_collection (
    order_id character varying(255) NOT NULL,
    payment_collection_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_payment_collection OWNER TO postgres;

--
-- Name: order_promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_promotion (
    order_id character varying(255) NOT NULL,
    promotion_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_promotion OWNER TO postgres;

--
-- Name: order_shipping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_shipping (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer NOT NULL,
    shipping_method_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_shipping OWNER TO postgres;

--
-- Name: order_shipping_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_shipping_method (
    id text NOT NULL,
    name text NOT NULL,
    description jsonb,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    shipping_option_id text,
    data jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    is_custom_amount boolean DEFAULT false NOT NULL
);


ALTER TABLE public.order_shipping_method OWNER TO postgres;

--
-- Name: order_shipping_method_adjustment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_shipping_method_adjustment (
    id text NOT NULL,
    description text,
    promotion_id text,
    code text,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_shipping_method_adjustment OWNER TO postgres;

--
-- Name: order_shipping_method_tax_line; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_shipping_method_tax_line (
    id text NOT NULL,
    description text,
    tax_rate_id text,
    code text NOT NULL,
    rate numeric NOT NULL,
    raw_rate jsonb NOT NULL,
    provider_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    shipping_method_id text NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_shipping_method_tax_line OWNER TO postgres;

--
-- Name: order_summary; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_summary (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    totals jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.order_summary OWNER TO postgres;

--
-- Name: order_transaction; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_transaction (
    id text NOT NULL,
    order_id text NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    reference text,
    reference_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    return_id text,
    claim_id text,
    exchange_id text
);


ALTER TABLE public.order_transaction OWNER TO postgres;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    currency_code text NOT NULL,
    provider_id text NOT NULL,
    data jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    captured_at timestamp with time zone,
    canceled_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    payment_session_id text NOT NULL,
    metadata jsonb
);


ALTER TABLE public.payment OWNER TO postgres;

--
-- Name: payment_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_collection (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    authorized_amount numeric,
    raw_authorized_amount jsonb,
    captured_amount numeric,
    raw_captured_amount jsonb,
    refunded_amount numeric,
    raw_refunded_amount jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    completed_at timestamp with time zone,
    status text DEFAULT 'not_paid'::text NOT NULL,
    metadata jsonb,
    CONSTRAINT payment_collection_status_check CHECK ((status = ANY (ARRAY['not_paid'::text, 'awaiting'::text, 'authorized'::text, 'partially_authorized'::text, 'canceled'::text, 'failed'::text, 'completed'::text])))
);


ALTER TABLE public.payment_collection OWNER TO postgres;

--
-- Name: payment_collection_payment_providers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_collection_payment_providers (
    payment_collection_id text NOT NULL,
    payment_provider_id text NOT NULL
);


ALTER TABLE public.payment_collection_payment_providers OWNER TO postgres;

--
-- Name: payment_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.payment_provider OWNER TO postgres;

--
-- Name: payment_session; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payment_session (
    id text NOT NULL,
    currency_code text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    provider_id text NOT NULL,
    data jsonb DEFAULT '{}'::jsonb NOT NULL,
    context jsonb,
    status text DEFAULT 'pending'::text NOT NULL,
    authorized_at timestamp with time zone,
    payment_collection_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT payment_session_status_check CHECK ((status = ANY (ARRAY['authorized'::text, 'captured'::text, 'pending'::text, 'requires_more'::text, 'error'::text, 'canceled'::text])))
);


ALTER TABLE public.payment_session OWNER TO postgres;

--
-- Name: price; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price (
    id text NOT NULL,
    title text,
    price_set_id text NOT NULL,
    currency_code text NOT NULL,
    raw_amount jsonb NOT NULL,
    rules_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    price_list_id text,
    amount numeric NOT NULL,
    min_quantity integer,
    max_quantity integer
);


ALTER TABLE public.price OWNER TO postgres;

--
-- Name: price_list; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_list (
    id text NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    rules_count integer DEFAULT 0,
    title text NOT NULL,
    description text NOT NULL,
    type text DEFAULT 'sale'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT price_list_status_check CHECK ((status = ANY (ARRAY['active'::text, 'draft'::text]))),
    CONSTRAINT price_list_type_check CHECK ((type = ANY (ARRAY['sale'::text, 'override'::text])))
);


ALTER TABLE public.price_list OWNER TO postgres;

--
-- Name: price_list_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_list_rule (
    id text NOT NULL,
    price_list_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    value jsonb,
    attribute text DEFAULT ''::text NOT NULL
);


ALTER TABLE public.price_list_rule OWNER TO postgres;

--
-- Name: price_preference; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_preference (
    id text NOT NULL,
    attribute text NOT NULL,
    value text,
    is_tax_inclusive boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.price_preference OWNER TO postgres;

--
-- Name: price_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_rule (
    id text NOT NULL,
    value text NOT NULL,
    priority integer DEFAULT 0 NOT NULL,
    price_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    attribute text DEFAULT ''::text NOT NULL,
    operator text DEFAULT 'eq'::text NOT NULL,
    CONSTRAINT price_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text])))
);


ALTER TABLE public.price_rule OWNER TO postgres;

--
-- Name: price_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.price_set (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.price_set OWNER TO postgres;

--
-- Name: product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    subtitle text,
    description text,
    is_giftcard boolean DEFAULT false NOT NULL,
    status text DEFAULT 'draft'::text NOT NULL,
    thumbnail text,
    weight text,
    length text,
    height text,
    width text,
    origin_country text,
    hs_code text,
    mid_code text,
    material text,
    collection_id text,
    type_id text,
    discountable boolean DEFAULT true NOT NULL,
    external_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb,
    CONSTRAINT product_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'proposed'::text, 'published'::text, 'rejected'::text])))
);


ALTER TABLE public.product OWNER TO postgres;

--
-- Name: product_category; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_category (
    id text NOT NULL,
    name text NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    handle text NOT NULL,
    mpath text NOT NULL,
    is_active boolean DEFAULT false NOT NULL,
    is_internal boolean DEFAULT false NOT NULL,
    rank integer DEFAULT 0 NOT NULL,
    parent_category_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    metadata jsonb
);


ALTER TABLE public.product_category OWNER TO postgres;

--
-- Name: product_category_product; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_category_product (
    product_id text NOT NULL,
    product_category_id text NOT NULL
);


ALTER TABLE public.product_category_product OWNER TO postgres;

--
-- Name: product_collection; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_collection (
    id text NOT NULL,
    title text NOT NULL,
    handle text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_collection OWNER TO postgres;

--
-- Name: product_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_option (
    id text NOT NULL,
    title text NOT NULL,
    product_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_option OWNER TO postgres;

--
-- Name: product_option_value; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_option_value (
    id text NOT NULL,
    value text NOT NULL,
    option_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_option_value OWNER TO postgres;

--
-- Name: product_sales_channel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_sales_channel (
    product_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_sales_channel OWNER TO postgres;

--
-- Name: product_shipping_profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_shipping_profile (
    product_id character varying(255) NOT NULL,
    shipping_profile_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_shipping_profile OWNER TO postgres;

--
-- Name: product_tag; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_tag (
    id text NOT NULL,
    value text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_tag OWNER TO postgres;

--
-- Name: product_tags; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_tags (
    product_id text NOT NULL,
    product_tag_id text NOT NULL
);


ALTER TABLE public.product_tags OWNER TO postgres;

--
-- Name: product_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_type (
    id text NOT NULL,
    value text NOT NULL,
    metadata json,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_type OWNER TO postgres;

--
-- Name: product_variant; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variant (
    id text NOT NULL,
    title text NOT NULL,
    sku text,
    barcode text,
    ean text,
    upc text,
    allow_backorder boolean DEFAULT false NOT NULL,
    manage_inventory boolean DEFAULT true NOT NULL,
    hs_code text,
    origin_country text,
    mid_code text,
    material text,
    weight integer,
    length integer,
    height integer,
    width integer,
    metadata jsonb,
    variant_rank integer DEFAULT 0,
    product_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant OWNER TO postgres;

--
-- Name: product_variant_inventory_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variant_inventory_item (
    variant_id character varying(255) NOT NULL,
    inventory_item_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    required_quantity integer DEFAULT 1 NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_inventory_item OWNER TO postgres;

--
-- Name: product_variant_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variant_option (
    variant_id text NOT NULL,
    option_value_id text NOT NULL
);


ALTER TABLE public.product_variant_option OWNER TO postgres;

--
-- Name: product_variant_price_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variant_price_set (
    variant_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.product_variant_price_set OWNER TO postgres;

--
-- Name: promotion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion (
    id text NOT NULL,
    code text NOT NULL,
    campaign_id text,
    is_automatic boolean DEFAULT false NOT NULL,
    type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    status text DEFAULT 'draft'::text NOT NULL,
    CONSTRAINT promotion_status_check CHECK ((status = ANY (ARRAY['draft'::text, 'active'::text, 'inactive'::text]))),
    CONSTRAINT promotion_type_check CHECK ((type = ANY (ARRAY['standard'::text, 'buyget'::text])))
);


ALTER TABLE public.promotion OWNER TO postgres;

--
-- Name: promotion_application_method; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_application_method (
    id text NOT NULL,
    value numeric,
    raw_value jsonb,
    max_quantity integer,
    apply_to_quantity integer,
    buy_rules_min_quantity integer,
    type text NOT NULL,
    target_type text NOT NULL,
    allocation text,
    promotion_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    CONSTRAINT promotion_application_method_allocation_check CHECK ((allocation = ANY (ARRAY['each'::text, 'across'::text]))),
    CONSTRAINT promotion_application_method_target_type_check CHECK ((target_type = ANY (ARRAY['order'::text, 'shipping_methods'::text, 'items'::text]))),
    CONSTRAINT promotion_application_method_type_check CHECK ((type = ANY (ARRAY['fixed'::text, 'percentage'::text])))
);


ALTER TABLE public.promotion_application_method OWNER TO postgres;

--
-- Name: promotion_campaign; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_campaign (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    campaign_identifier text NOT NULL,
    starts_at timestamp with time zone,
    ends_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.promotion_campaign OWNER TO postgres;

--
-- Name: promotion_campaign_budget; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_campaign_budget (
    id text NOT NULL,
    type text NOT NULL,
    campaign_id text NOT NULL,
    "limit" numeric,
    raw_limit jsonb,
    used numeric DEFAULT 0 NOT NULL,
    raw_used jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    currency_code text,
    CONSTRAINT promotion_campaign_budget_type_check CHECK ((type = ANY (ARRAY['spend'::text, 'usage'::text])))
);


ALTER TABLE public.promotion_campaign_budget OWNER TO postgres;

--
-- Name: promotion_promotion_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_promotion_rule (
    promotion_id text NOT NULL,
    promotion_rule_id text NOT NULL
);


ALTER TABLE public.promotion_promotion_rule OWNER TO postgres;

--
-- Name: promotion_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_rule (
    id text NOT NULL,
    description text,
    attribute text NOT NULL,
    operator text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT promotion_rule_operator_check CHECK ((operator = ANY (ARRAY['gte'::text, 'lte'::text, 'gt'::text, 'lt'::text, 'eq'::text, 'ne'::text, 'in'::text])))
);


ALTER TABLE public.promotion_rule OWNER TO postgres;

--
-- Name: promotion_rule_value; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.promotion_rule_value (
    id text NOT NULL,
    promotion_rule_id text NOT NULL,
    value text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.promotion_rule_value OWNER TO postgres;

--
-- Name: provider_identity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.provider_identity (
    id text NOT NULL,
    entity_id text NOT NULL,
    provider text NOT NULL,
    auth_identity_id text NOT NULL,
    user_metadata jsonb,
    provider_metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.provider_identity OWNER TO postgres;

--
-- Name: publishable_api_key_sales_channel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.publishable_api_key_sales_channel (
    publishable_key_id character varying(255) NOT NULL,
    sales_channel_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.publishable_api_key_sales_channel OWNER TO postgres;

--
-- Name: refund; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refund (
    id text NOT NULL,
    amount numeric NOT NULL,
    raw_amount jsonb NOT NULL,
    payment_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    created_by text,
    metadata jsonb,
    refund_reason_id text,
    note text
);


ALTER TABLE public.refund OWNER TO postgres;

--
-- Name: refund_reason; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.refund_reason (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.refund_reason OWNER TO postgres;

--
-- Name: region; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.region (
    id text NOT NULL,
    name text NOT NULL,
    currency_code text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    automatic_taxes boolean DEFAULT true NOT NULL
);


ALTER TABLE public.region OWNER TO postgres;

--
-- Name: region_country; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.region_country (
    iso_2 text NOT NULL,
    iso_3 text NOT NULL,
    num_code text NOT NULL,
    name text NOT NULL,
    display_name text NOT NULL,
    region_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.region_country OWNER TO postgres;

--
-- Name: region_payment_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.region_payment_provider (
    region_id character varying(255) NOT NULL,
    payment_provider_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.region_payment_provider OWNER TO postgres;

--
-- Name: reservation_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.reservation_item (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    line_item_id text,
    location_id text NOT NULL,
    quantity numeric NOT NULL,
    external_id text,
    description text,
    created_by text,
    metadata jsonb,
    inventory_item_id text NOT NULL,
    allow_backorder boolean DEFAULT false,
    raw_quantity jsonb
);


ALTER TABLE public.reservation_item OWNER TO postgres;

--
-- Name: return; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return (
    id text NOT NULL,
    order_id text NOT NULL,
    claim_id text,
    exchange_id text,
    order_version integer NOT NULL,
    display_id integer NOT NULL,
    status public.return_status_enum DEFAULT 'open'::public.return_status_enum NOT NULL,
    no_notification boolean,
    refund_amount numeric,
    raw_refund_amount jsonb,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    received_at timestamp with time zone,
    canceled_at timestamp with time zone,
    location_id text,
    requested_at timestamp with time zone,
    created_by text
);


ALTER TABLE public.return OWNER TO postgres;

--
-- Name: return_display_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.return_display_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.return_display_id_seq OWNER TO postgres;

--
-- Name: return_display_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.return_display_id_seq OWNED BY public.return.display_id;


--
-- Name: return_fulfillment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return_fulfillment (
    return_id character varying(255) NOT NULL,
    fulfillment_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.return_fulfillment OWNER TO postgres;

--
-- Name: return_item; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return_item (
    id text NOT NULL,
    return_id text NOT NULL,
    reason_id text,
    item_id text NOT NULL,
    quantity numeric NOT NULL,
    raw_quantity jsonb NOT NULL,
    received_quantity numeric DEFAULT 0 NOT NULL,
    raw_received_quantity jsonb NOT NULL,
    note text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    damaged_quantity numeric DEFAULT 0 NOT NULL,
    raw_damaged_quantity jsonb NOT NULL
);


ALTER TABLE public.return_item OWNER TO postgres;

--
-- Name: return_reason; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.return_reason (
    id character varying NOT NULL,
    value character varying NOT NULL,
    label character varying NOT NULL,
    description character varying,
    metadata jsonb,
    parent_return_reason_id character varying,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.return_reason OWNER TO postgres;

--
-- Name: sales_channel; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_channel (
    id text NOT NULL,
    name text NOT NULL,
    description text,
    is_disabled boolean DEFAULT false NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.sales_channel OWNER TO postgres;

--
-- Name: sales_channel_stock_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sales_channel_stock_location (
    sales_channel_id character varying(255) NOT NULL,
    stock_location_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.sales_channel_stock_location OWNER TO postgres;

--
-- Name: script_migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.script_migrations (
    id integer NOT NULL,
    script_name character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    finished_at timestamp with time zone
);


ALTER TABLE public.script_migrations OWNER TO postgres;

--
-- Name: script_migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.script_migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.script_migrations_id_seq OWNER TO postgres;

--
-- Name: script_migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.script_migrations_id_seq OWNED BY public.script_migrations.id;


--
-- Name: service_zone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.service_zone (
    id text NOT NULL,
    name text NOT NULL,
    metadata jsonb,
    fulfillment_set_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.service_zone OWNER TO postgres;

--
-- Name: shipping_option; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_option (
    id text NOT NULL,
    name text NOT NULL,
    price_type text DEFAULT 'flat'::text NOT NULL,
    service_zone_id text NOT NULL,
    shipping_profile_id text,
    provider_id text,
    data jsonb,
    metadata jsonb,
    shipping_option_type_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_price_type_check CHECK ((price_type = ANY (ARRAY['calculated'::text, 'flat'::text])))
);


ALTER TABLE public.shipping_option OWNER TO postgres;

--
-- Name: shipping_option_price_set; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_option_price_set (
    shipping_option_id character varying(255) NOT NULL,
    price_set_id character varying(255) NOT NULL,
    id character varying(255) NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_option_price_set OWNER TO postgres;

--
-- Name: shipping_option_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_option_rule (
    id text NOT NULL,
    attribute text NOT NULL,
    operator text NOT NULL,
    value jsonb,
    shipping_option_id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT shipping_option_rule_operator_check CHECK ((operator = ANY (ARRAY['in'::text, 'eq'::text, 'ne'::text, 'gt'::text, 'gte'::text, 'lt'::text, 'lte'::text, 'nin'::text])))
);


ALTER TABLE public.shipping_option_rule OWNER TO postgres;

--
-- Name: shipping_option_type; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_option_type (
    id text NOT NULL,
    label text NOT NULL,
    description text,
    code text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_option_type OWNER TO postgres;

--
-- Name: shipping_profile; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shipping_profile (
    id text NOT NULL,
    name text NOT NULL,
    type text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.shipping_profile OWNER TO postgres;

--
-- Name: stock_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_location (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    name text NOT NULL,
    address_id text,
    metadata jsonb
);


ALTER TABLE public.stock_location OWNER TO postgres;

--
-- Name: stock_location_address; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_location_address (
    id text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    address_1 text NOT NULL,
    address_2 text,
    company text,
    city text,
    country_code text NOT NULL,
    phone text,
    province text,
    postal_code text,
    metadata jsonb
);


ALTER TABLE public.stock_location_address OWNER TO postgres;

--
-- Name: store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store (
    id text NOT NULL,
    name text DEFAULT 'Medusa Store'::text NOT NULL,
    default_sales_channel_id text,
    default_region_id text,
    default_location_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.store OWNER TO postgres;

--
-- Name: store_currency; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.store_currency (
    id text NOT NULL,
    currency_code text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    store_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.store_currency OWNER TO postgres;

--
-- Name: tax_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_provider (
    id text NOT NULL,
    is_enabled boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_provider OWNER TO postgres;

--
-- Name: tax_rate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_rate (
    id text NOT NULL,
    rate real,
    code text NOT NULL,
    name text NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_combinable boolean DEFAULT false NOT NULL,
    tax_region_id text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_rate OWNER TO postgres;

--
-- Name: tax_rate_rule; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_rate_rule (
    id text NOT NULL,
    tax_rate_id text NOT NULL,
    reference_id text NOT NULL,
    reference text NOT NULL,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone
);


ALTER TABLE public.tax_rate_rule OWNER TO postgres;

--
-- Name: tax_region; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.tax_region (
    id text NOT NULL,
    provider_id text,
    country_code text NOT NULL,
    province_code text,
    parent_id text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_by text,
    deleted_at timestamp with time zone,
    CONSTRAINT "CK_tax_region_country_top_level" CHECK (((parent_id IS NULL) OR (province_code IS NOT NULL))),
    CONSTRAINT "CK_tax_region_provider_top_level" CHECK (((parent_id IS NULL) OR (provider_id IS NULL)))
);


ALTER TABLE public.tax_region OWNER TO postgres;

--
-- Name: user; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public."user" (
    id text NOT NULL,
    first_name text,
    last_name text,
    email text NOT NULL,
    avatar_url text,
    metadata jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public."user" OWNER TO postgres;

--
-- Name: workflow_execution; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workflow_execution (
    id character varying NOT NULL,
    workflow_id character varying NOT NULL,
    transaction_id character varying NOT NULL,
    execution jsonb,
    context jsonb,
    state character varying NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL,
    updated_at timestamp without time zone DEFAULT now() NOT NULL,
    deleted_at timestamp without time zone,
    retention_time integer
);


ALTER TABLE public.workflow_execution OWNER TO postgres;

--
-- Name: link_module_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.link_module_migrations ALTER COLUMN id SET DEFAULT nextval('public.link_module_migrations_id_seq'::regclass);


--
-- Name: mikro_orm_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mikro_orm_migrations ALTER COLUMN id SET DEFAULT nextval('public.mikro_orm_migrations_id_seq'::regclass);


--
-- Name: order display_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order" ALTER COLUMN display_id SET DEFAULT nextval('public.order_display_id_seq'::regclass);


--
-- Name: order_change_action ordering; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change_action ALTER COLUMN ordering SET DEFAULT nextval('public.order_change_action_ordering_seq'::regclass);


--
-- Name: order_claim display_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_claim ALTER COLUMN display_id SET DEFAULT nextval('public.order_claim_display_id_seq'::regclass);


--
-- Name: order_exchange display_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_exchange ALTER COLUMN display_id SET DEFAULT nextval('public.order_exchange_display_id_seq'::regclass);


--
-- Name: return display_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return ALTER COLUMN display_id SET DEFAULT nextval('public.return_display_id_seq'::regclass);


--
-- Name: script_migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.script_migrations ALTER COLUMN id SET DEFAULT nextval('public.script_migrations_id_seq'::regclass);


--
-- Data for Name: account_holder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.account_holder (id, provider_id, external_id, email, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: api_key; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.api_key (id, token, salt, redacted, title, type, last_used_at, created_by, created_at, revoked_by, revoked_at, updated_at, deleted_at) FROM stdin;
apk_01JM18DSHY8A33T4ZEH21XJHE9	pk_496318b0f51cebab1266557ec05026c2a45eee1eb38f58fc9031c1d205ee769b		pk_496***69b	Webshop	publishable	\N		2025-02-14 03:35:50.078+00	\N	\N	2025-02-14 03:35:50.078+00	\N
\.


--
-- Data for Name: application_method_buy_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.application_method_buy_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: application_method_target_rules; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.application_method_target_rules (application_method_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.auth_identity (id, app_metadata, created_at, updated_at, deleted_at) FROM stdin;
authid_01JM18EDN6FQJ72ZAEVRK8152P	{"user_id": "user_01JM18EDP3GPD7FCRAZJ18FVS3"}	2025-02-14 03:36:10.662+00	2025-02-14 03:36:10.713+00	\N
\.


--
-- Data for Name: capture; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.capture (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata) FROM stdin;
\.


--
-- Data for Name: cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart (id, region_id, customer_id, sales_channel_id, email, currency_code, shipping_address_id, billing_address_id, metadata, created_at, updated_at, deleted_at, completed_at) FROM stdin;
\.


--
-- Data for Name: cart_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_line_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_line_item (id, cart_id, title, subtitle, thumbnail, quantity, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, product_type_id, is_custom_price) FROM stdin;
\.


--
-- Data for Name: cart_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, item_id) FROM stdin;
\.


--
-- Data for Name: cart_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_line_item_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, item_id) FROM stdin;
\.


--
-- Data for Name: cart_payment_collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_payment_collection (cart_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_promotion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_promotion (cart_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_shipping_method (id, cart_id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: cart_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cart_shipping_method_tax_line (id, description, tax_rate_id, code, rate, provider_id, metadata, created_at, updated_at, deleted_at, shipping_method_id) FROM stdin;
\.


--
-- Data for Name: currency; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.currency (code, symbol, symbol_native, decimal_digits, rounding, raw_rounding, name, created_at, updated_at, deleted_at) FROM stdin;
usd	$	$	2	0	{"value": "0", "precision": 20}	US Dollar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
cad	CA$	$	2	0	{"value": "0", "precision": 20}	Canadian Dollar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
eur	€	€	2	0	{"value": "0", "precision": 20}	Euro	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
aed	AED	د.إ.‏	2	0	{"value": "0", "precision": 20}	United Arab Emirates Dirham	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
afn	Af	؋	0	0	{"value": "0", "precision": 20}	Afghan Afghani	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
all	ALL	Lek	0	0	{"value": "0", "precision": 20}	Albanian Lek	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
amd	AMD	դր.	0	0	{"value": "0", "precision": 20}	Armenian Dram	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
ars	AR$	$	2	0	{"value": "0", "precision": 20}	Argentine Peso	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
aud	AU$	$	2	0	{"value": "0", "precision": 20}	Australian Dollar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
azn	man.	ман.	2	0	{"value": "0", "precision": 20}	Azerbaijani Manat	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bam	KM	KM	2	0	{"value": "0", "precision": 20}	Bosnia-Herzegovina Convertible Mark	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bdt	Tk	৳	2	0	{"value": "0", "precision": 20}	Bangladeshi Taka	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bgn	BGN	лв.	2	0	{"value": "0", "precision": 20}	Bulgarian Lev	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bhd	BD	د.ب.‏	3	0	{"value": "0", "precision": 20}	Bahraini Dinar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bif	FBu	FBu	0	0	{"value": "0", "precision": 20}	Burundian Franc	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bnd	BN$	$	2	0	{"value": "0", "precision": 20}	Brunei Dollar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bob	Bs	Bs	2	0	{"value": "0", "precision": 20}	Bolivian Boliviano	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
brl	R$	R$	2	0	{"value": "0", "precision": 20}	Brazilian Real	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bwp	BWP	P	2	0	{"value": "0", "precision": 20}	Botswanan Pula	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
byn	Br	руб.	2	0	{"value": "0", "precision": 20}	Belarusian Ruble	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
bzd	BZ$	$	2	0	{"value": "0", "precision": 20}	Belize Dollar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
cdf	CDF	FrCD	2	0	{"value": "0", "precision": 20}	Congolese Franc	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
chf	CHF	CHF	2	0.05	{"value": "0.05", "precision": 20}	Swiss Franc	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
clp	CL$	$	0	0	{"value": "0", "precision": 20}	Chilean Peso	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
cny	CN¥	CN¥	2	0	{"value": "0", "precision": 20}	Chinese Yuan	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
cop	CO$	$	0	0	{"value": "0", "precision": 20}	Colombian Peso	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
crc	₡	₡	0	0	{"value": "0", "precision": 20}	Costa Rican Colón	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
cve	CV$	CV$	2	0	{"value": "0", "precision": 20}	Cape Verdean Escudo	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
czk	Kč	Kč	2	0	{"value": "0", "precision": 20}	Czech Republic Koruna	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
djf	Fdj	Fdj	0	0	{"value": "0", "precision": 20}	Djiboutian Franc	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
dkk	Dkr	kr	2	0	{"value": "0", "precision": 20}	Danish Krone	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
dop	RD$	RD$	2	0	{"value": "0", "precision": 20}	Dominican Peso	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
dzd	DA	د.ج.‏	2	0	{"value": "0", "precision": 20}	Algerian Dinar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
eek	Ekr	kr	2	0	{"value": "0", "precision": 20}	Estonian Kroon	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
egp	EGP	ج.م.‏	2	0	{"value": "0", "precision": 20}	Egyptian Pound	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
ern	Nfk	Nfk	2	0	{"value": "0", "precision": 20}	Eritrean Nakfa	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
etb	Br	Br	2	0	{"value": "0", "precision": 20}	Ethiopian Birr	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
gbp	£	£	2	0	{"value": "0", "precision": 20}	British Pound Sterling	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
gel	GEL	GEL	2	0	{"value": "0", "precision": 20}	Georgian Lari	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
ghs	GH₵	GH₵	2	0	{"value": "0", "precision": 20}	Ghanaian Cedi	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
gnf	FG	FG	0	0	{"value": "0", "precision": 20}	Guinean Franc	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
gtq	GTQ	Q	2	0	{"value": "0", "precision": 20}	Guatemalan Quetzal	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
hkd	HK$	$	2	0	{"value": "0", "precision": 20}	Hong Kong Dollar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
hnl	HNL	L	2	0	{"value": "0", "precision": 20}	Honduran Lempira	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
hrk	kn	kn	2	0	{"value": "0", "precision": 20}	Croatian Kuna	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
huf	Ft	Ft	0	0	{"value": "0", "precision": 20}	Hungarian Forint	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
idr	Rp	Rp	0	0	{"value": "0", "precision": 20}	Indonesian Rupiah	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
ils	₪	₪	2	0	{"value": "0", "precision": 20}	Israeli New Sheqel	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
inr	Rs	₹	2	0	{"value": "0", "precision": 20}	Indian Rupee	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
iqd	IQD	د.ع.‏	0	0	{"value": "0", "precision": 20}	Iraqi Dinar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
irr	IRR	﷼	0	0	{"value": "0", "precision": 20}	Iranian Rial	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
isk	Ikr	kr	0	0	{"value": "0", "precision": 20}	Icelandic Króna	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
jmd	J$	$	2	0	{"value": "0", "precision": 20}	Jamaican Dollar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
jod	JD	د.أ.‏	3	0	{"value": "0", "precision": 20}	Jordanian Dinar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
jpy	¥	￥	0	0	{"value": "0", "precision": 20}	Japanese Yen	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
kes	Ksh	Ksh	2	0	{"value": "0", "precision": 20}	Kenyan Shilling	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
khr	KHR	៛	2	0	{"value": "0", "precision": 20}	Cambodian Riel	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
kmf	CF	FC	0	0	{"value": "0", "precision": 20}	Comorian Franc	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
krw	₩	₩	0	0	{"value": "0", "precision": 20}	South Korean Won	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
kwd	KD	د.ك.‏	3	0	{"value": "0", "precision": 20}	Kuwaiti Dinar	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
kzt	KZT	тңг.	2	0	{"value": "0", "precision": 20}	Kazakhstani Tenge	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
lbp	LB£	ل.ل.‏	0	0	{"value": "0", "precision": 20}	Lebanese Pound	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
lkr	SLRs	SL Re	2	0	{"value": "0", "precision": 20}	Sri Lankan Rupee	2025-02-14 03:35:46.072+00	2025-02-14 03:35:46.072+00	\N
ltl	Lt	Lt	2	0	{"value": "0", "precision": 20}	Lithuanian Litas	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
lvl	Ls	Ls	2	0	{"value": "0", "precision": 20}	Latvian Lats	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
lyd	LD	د.ل.‏	3	0	{"value": "0", "precision": 20}	Libyan Dinar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mad	MAD	د.م.‏	2	0	{"value": "0", "precision": 20}	Moroccan Dirham	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mdl	MDL	MDL	2	0	{"value": "0", "precision": 20}	Moldovan Leu	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mga	MGA	MGA	0	0	{"value": "0", "precision": 20}	Malagasy Ariary	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mkd	MKD	MKD	2	0	{"value": "0", "precision": 20}	Macedonian Denar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mmk	MMK	K	0	0	{"value": "0", "precision": 20}	Myanma Kyat	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mnt	MNT	₮	0	0	{"value": "0", "precision": 20}	Mongolian Tugrig	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mop	MOP$	MOP$	2	0	{"value": "0", "precision": 20}	Macanese Pataca	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mur	MURs	MURs	0	0	{"value": "0", "precision": 20}	Mauritian Rupee	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mxn	MX$	$	2	0	{"value": "0", "precision": 20}	Mexican Peso	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
myr	RM	RM	2	0	{"value": "0", "precision": 20}	Malaysian Ringgit	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
mzn	MTn	MTn	2	0	{"value": "0", "precision": 20}	Mozambican Metical	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
nad	N$	N$	2	0	{"value": "0", "precision": 20}	Namibian Dollar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
ngn	₦	₦	2	0	{"value": "0", "precision": 20}	Nigerian Naira	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
nio	C$	C$	2	0	{"value": "0", "precision": 20}	Nicaraguan Córdoba	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
nok	Nkr	kr	2	0	{"value": "0", "precision": 20}	Norwegian Krone	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
npr	NPRs	नेरू	2	0	{"value": "0", "precision": 20}	Nepalese Rupee	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
nzd	NZ$	$	2	0	{"value": "0", "precision": 20}	New Zealand Dollar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
omr	OMR	ر.ع.‏	3	0	{"value": "0", "precision": 20}	Omani Rial	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
pab	B/.	B/.	2	0	{"value": "0", "precision": 20}	Panamanian Balboa	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
pen	S/.	S/.	2	0	{"value": "0", "precision": 20}	Peruvian Nuevo Sol	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
php	₱	₱	2	0	{"value": "0", "precision": 20}	Philippine Peso	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
pkr	PKRs	₨	0	0	{"value": "0", "precision": 20}	Pakistani Rupee	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
pln	zł	zł	2	0	{"value": "0", "precision": 20}	Polish Zloty	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
pyg	₲	₲	0	0	{"value": "0", "precision": 20}	Paraguayan Guarani	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
qar	QR	ر.ق.‏	2	0	{"value": "0", "precision": 20}	Qatari Rial	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
ron	RON	RON	2	0	{"value": "0", "precision": 20}	Romanian Leu	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
rsd	din.	дин.	0	0	{"value": "0", "precision": 20}	Serbian Dinar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
rub	RUB	₽.	2	0	{"value": "0", "precision": 20}	Russian Ruble	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
rwf	RWF	FR	0	0	{"value": "0", "precision": 20}	Rwandan Franc	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
sar	SR	ر.س.‏	2	0	{"value": "0", "precision": 20}	Saudi Riyal	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
sdg	SDG	SDG	2	0	{"value": "0", "precision": 20}	Sudanese Pound	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
sek	Skr	kr	2	0	{"value": "0", "precision": 20}	Swedish Krona	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
sgd	S$	$	2	0	{"value": "0", "precision": 20}	Singapore Dollar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
sos	Ssh	Ssh	0	0	{"value": "0", "precision": 20}	Somali Shilling	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
syp	SY£	ل.س.‏	0	0	{"value": "0", "precision": 20}	Syrian Pound	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
thb	฿	฿	2	0	{"value": "0", "precision": 20}	Thai Baht	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
tnd	DT	د.ت.‏	3	0	{"value": "0", "precision": 20}	Tunisian Dinar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
top	T$	T$	2	0	{"value": "0", "precision": 20}	Tongan Paʻanga	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
try	₺	₺	2	0	{"value": "0", "precision": 20}	Turkish Lira	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
ttd	TT$	$	2	0	{"value": "0", "precision": 20}	Trinidad and Tobago Dollar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
twd	NT$	NT$	2	0	{"value": "0", "precision": 20}	New Taiwan Dollar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
tzs	TSh	TSh	0	0	{"value": "0", "precision": 20}	Tanzanian Shilling	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
uah	₴	₴	2	0	{"value": "0", "precision": 20}	Ukrainian Hryvnia	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
ugx	USh	USh	0	0	{"value": "0", "precision": 20}	Ugandan Shilling	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
uyu	$U	$	2	0	{"value": "0", "precision": 20}	Uruguayan Peso	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
uzs	UZS	UZS	0	0	{"value": "0", "precision": 20}	Uzbekistan Som	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
vef	Bs.F.	Bs.F.	2	0	{"value": "0", "precision": 20}	Venezuelan Bolívar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
vnd	₫	₫	0	0	{"value": "0", "precision": 20}	Vietnamese Dong	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
xaf	FCFA	FCFA	0	0	{"value": "0", "precision": 20}	CFA Franc BEAC	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
xof	CFA	CFA	0	0	{"value": "0", "precision": 20}	CFA Franc BCEAO	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
yer	YR	ر.ي.‏	0	0	{"value": "0", "precision": 20}	Yemeni Rial	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
zar	R	R	2	0	{"value": "0", "precision": 20}	South African Rand	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
zmk	ZK	ZK	0	0	{"value": "0", "precision": 20}	Zambian Kwacha	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
zwl	ZWL$	ZWL$	0	0	{"value": "0", "precision": 20}	Zimbabwean Dollar	2025-02-14 03:35:46.073+00	2025-02-14 03:35:46.073+00	\N
\.


--
-- Data for Name: customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer (id, company_name, first_name, last_name, email, phone, has_account, metadata, created_at, updated_at, deleted_at, created_by) FROM stdin;
\.


--
-- Data for Name: customer_account_holder; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_account_holder (customer_id, account_holder_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_address (id, customer_id, address_name, is_default_shipping, is_default_billing, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_group (id, name, metadata, created_by, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: customer_group_customer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_group_customer (id, customer_id, customer_group_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment (id, location_id, packed_at, shipped_at, delivered_at, canceled_at, data, provider_id, shipping_option_id, metadata, delivery_address_id, created_at, updated_at, deleted_at, marked_shipped_by, created_by, requires_shipping) FROM stdin;
\.


--
-- Data for Name: fulfillment_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_address (id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_item (id, title, sku, barcode, quantity, raw_quantity, line_item_id, inventory_item_id, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_label; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_label (id, tracking_number, tracking_url, label_url, fulfillment_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
manual_manual	t	2025-02-14 03:35:46.197+00	2025-02-14 03:35:46.197+00	\N
\.


--
-- Data for Name: fulfillment_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fulfillment_set (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
fuset_01JM18DSFMAVM37G1C672XYWBZ	European Warehouse delivery	shipping	\N	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
\.


--
-- Data for Name: geo_zone; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.geo_zone (id, type, country_code, province_code, city, service_zone_id, postal_expression, metadata, created_at, updated_at, deleted_at) FROM stdin;
fgz_01JM18DSFKX30VJB423C4X659J	country	gb	\N	\N	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	\N	\N	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
fgz_01JM18DSFK4QCB7XN7TGYY9FNV	country	de	\N	\N	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	\N	\N	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
fgz_01JM18DSFKXT2XQ4QE8TEXFRJX	country	dk	\N	\N	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	\N	\N	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
fgz_01JM18DSFKKTV3TR3ZGQXTRK5R	country	se	\N	\N	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	\N	\N	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
fgz_01JM18DSFKDXSWVYBJ90WWF0H7	country	fr	\N	\N	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	\N	\N	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
fgz_01JM18DSFM1EXF4KMBWX33783J	country	es	\N	\N	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	\N	\N	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
fgz_01JM18DSFMD7QQYYEBBKTN4MX2	country	it	\N	\N	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	\N	\N	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
\.


--
-- Data for Name: image; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.image (id, url, metadata, created_at, updated_at, deleted_at, rank, product_id) FROM stdin;
img_01JM18DSM6GWTSJFGN2TR5YDVS	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV
img_01JM18DSM6C7EGA0D4KZKBT1SY	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-back.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	1	prod_01JM18DSK7TAY1V51GANPG18AV
img_01JM18DSM63SEE5TMN1XGXFQGQ	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-front.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	2	prod_01JM18DSK7TAY1V51GANPG18AV
img_01JM18DSM604VDKDKHM36Z7T7S	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-white-back.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	3	prod_01JM18DSK7TAY1V51GANPG18AV
img_01JM18DSM8CJBXX3GAK68MW08E	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	0	prod_01JM18DSK7W9Z90KJWFD1KCV2B
img_01JM18DSM8Q8R1P1HJAR75NYE2	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-back.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	1	prod_01JM18DSK7W9Z90KJWFD1KCV2B
img_01JM18DSMA60DZ1AVKCAWTRA8K	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	0	prod_01JM18DSK7815R7Y7SR83MPR32
img_01JM18DSMAAV515C305XHW80ZR	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-back.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	1	prod_01JM18DSK7815R7Y7SR83MPR32
img_01JM18DSMCZRFHF40HFZWFFJMR	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	0	prod_01JM18DSK77PEYBDSR2C19BESV
img_01JM18DSMCYBDPD6E4ZAFBG73M	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-back.png	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	1	prod_01JM18DSK77PEYBDSR2C19BESV
img_01JM2DWYHVW659BENMTN6Y5JP7	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	0	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHV1KARE2T0RKWRHZKZ	https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	1	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHW3QD4SWN3XEK761AQ	https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	2	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWYA1WFYBVJDDHT0WB	https://interioricons.com/cdn/shop/files/4607-1_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	3	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWJW4448R4MF1FRADK	https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	4	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHW33SVKY26ZWVJ0NXK	https://interioricons.com/cdn/shop/files/4607-2_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	5	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHW2RJ92CMX12Q3PP2Q	https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	6	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWR3AJED462H4N8QQF	https://interioricons.com/cdn/shop/files/4607-3_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	7	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWQGP9840RVF8F12MK	https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	8	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHW5NQD6Y3WRXGCZDKT	https://interioricons.com/cdn/shop/files/4607-4_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	9	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWRV187HKFQ2DKRN6D	https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	10	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWZ9BTWA0CSZBZV0DP	https://interioricons.com/cdn/shop/files/4607-5_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	11	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHW8YYBVX81RW2T2V4Q	https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	12	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHW7JYDSV54QJEKHXVE	https://interioricons.com/cdn/shop/files/4607-10_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	13	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHW8SET5TG2ZC77K80Q	https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	14	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWK10DGV44Z6GEZKN4	https://interioricons.com/cdn/shop/files/4607-11_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	15	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWE85GDPP13QJ5ZA8H	https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	16	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWQA8F1DY5B1Z9GMH1	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	17	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWCGCPG9Z6ZQ45GKA0	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	18	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWHVQ4AB8QV1MK04AW	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	19	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHWC7XRTQ64ENM6G9M5	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	20	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHW99HJ7J0Q0EX4RARV	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	21	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHX1DT6YPKZNDEWF4FT	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	22	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXM064VAJN8YRE7M4D	https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	23	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHX459HREKRWQDKZ7JA	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	24	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXNFEP5A4D0WSR4EV8	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	25	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXFV4VETXV0W2AAVQ4	https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	26	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXBKPYSRFBNPXT8MSX	https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	27	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHX2M6TWH954D642DC1	https://interioricons.com/cdn/shop/files/2184-1_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	28	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHX1DRH7D65GXV8KGGW	https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	29	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHX7RNHBEHP25A1XYYD	https://interioricons.com/cdn/shop/files/2149-1_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00	30	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHX1NV11VN68WG749E6	https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	31	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXDN2GX022X80EG2KQ	https://interioricons.com/cdn/shop/files/2028-1_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	32	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXCYKH9CF80C6AZN23	https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	33	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2HQQ5N16SQEEJTEYP9SDCA	https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	10	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NRKKAX3TDGKS3WGSX	https://interioricons.com/cdn/shop/files/4607-5_640x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	11	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NQK78VHD87PZBAFPP	https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	12	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NSJ601FH1QBC2YGN3	https://interioricons.com/cdn/shop/files/4607-10_640x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	13	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NBC144R5HEAVH600D	https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	14	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5N3AH8W5137YRBCJ15	https://interioricons.com/cdn/shop/files/4607-11_640x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	15	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5N52TTZDTZWP026BRB	https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	16	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5N660CYYJMPTJ3X6SX	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	17	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NE3963E49DBK28F6P	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	18	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NBHNQGS7AP4P3V7PF	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	19	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NMFCQRKJ67QWD09N7	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	20	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5N9XE30TT3CDHTJHF8	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	21	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NF1NG4Z174ME6TPRX	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	22	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NQ9WYXMBFEE33HWW4	https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	23	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5P65TB0V5VHQGCANQK	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	24	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5P2NGP99JP9M1ZZXKQ	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	25	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5PHBG09PFSCY3HTPET	https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	26	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5PW7ZHHXWQC7NV1B92	https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	27	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2D2W0X5RK3R8YVY99DNTBS	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	0	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0XF03MWHP2YWTTHTKN	https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	1	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0X3VZ5YK36E1R5ARRN	https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	2	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0X8K81441MV7YNWQMZ	https://interioricons.com/cdn/shop/files/4607-1_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	3	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0XW0SM2MEB5Q4ADBFM	https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	4	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0X7SM1YWKQ3QKBHX4E	https://interioricons.com/cdn/shop/files/4607-2_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	5	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YV111W0W8GS3JYWTR	https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	6	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y74DE4R6H3TSG1MSV	https://interioricons.com/cdn/shop/files/4607-3_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	7	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y7XFXHD0EQ5N1PQHM	https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	8	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YH65ZV1CXZCKABEBP	https://interioricons.com/cdn/shop/files/4607-4_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	9	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YH5R7YMKC4SGSXYVX	https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	10	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y0ZC6MEQ6QRCESH3A	https://interioricons.com/cdn/shop/files/4607-5_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	11	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YS9BTMAMNJBN95WNV	https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	12	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YC04PNEEB3FQAVBKH	https://interioricons.com/cdn/shop/files/4607-10_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	13	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YPB1GYSNTGMZMQMKR	https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	14	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y69N09A0F9ZE3GFGC	https://interioricons.com/cdn/shop/files/4607-11_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	15	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y8P07A53J3A0EKB0E	https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00	16	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y3GQWK8KEYBCQT1N3	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	17	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y06MC678CME7GWW8E	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	18	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YMW88DS14690TJ5AD	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	19	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YVGQ9HQ1ZE7DZ874A	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	20	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YM61PR3HZRFJQMNSS	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	21	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y9R825317PGYP4158	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	22	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Y45WKACZK2CEQSPJZ	https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	23	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YZA570D3QR0N6TPH1	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	24	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0YJJ390J2572CVQCKP	https://interioricons.com/cdn/shop/files/4607-1_60x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	25	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZY5MBQTZ2AE2VK5AM	https://interioricons.com/cdn/shop/files/4607-2_60x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	26	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Z59Q41JFSJDFDVGE2	https://interioricons.com/cdn/shop/files/4607-3_60x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	27	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZJSEZCV2PA0QP22BK	https://interioricons.com/cdn/shop/files/4607-4_60x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	28	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZJ7AMHRVETYPW8DWB	https://interioricons.com/cdn/shop/files/4607-5_60x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	29	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZQHCYPDEMS48BEVR8	https://interioricons.com/cdn/shop/files/4607-10_60x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	30	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Z22NX07473PDREY64	https://interioricons.com/cdn/shop/files/4607-11_60x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	31	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZHCYNEQZR5XQ4TA5H	https://interioricons.com/cdn/shop/files/4607-12_60x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	32	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZXZAJW5V3F406CQKW	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	33	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZVEGY0K7J7R7KV7SK	https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	34	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Z9DN1Z8PJ3P3W7930	https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	35	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZBCW4TKG4EXE123MN	https://interioricons.com/cdn/shop/files/2184-1_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	36	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZXGFBFG178WTW1ZGB	https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	37	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Z770D6E2EWB1J403Q	https://interioricons.com/cdn/shop/files/2149-1_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	38	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZZQPA5J4NCBSCFFKC	https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	39	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZNEN8ZRR6M2WM2EC6	https://interioricons.com/cdn/shop/files/2028-1_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	40	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Z09DFV48ZDPP7SXKS	https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	41	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZWZRP7NE14Y9AM32T	https://interioricons.com/cdn/shop/files/1635-1_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	42	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZYZDDM5P8E648391J	https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	43	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZHACQ02YDW7A3NDF2	https://interioricons.com/cdn/shop/files/2333-2_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	44	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Z0BP9XZBF11YZ2FQ9	https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	45	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZHG5ZF74THEFJ1C2Z	https://interioricons.com/cdn/shop/files/1738-5_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	46	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Z1S3A6KBCXK6NBQFC	https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	47	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZAVBMA4KQBPVR40X1	https://interioricons.com/cdn/shop/files/1739-3_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	48	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0ZMPAPJ2VVM49KMMDQ	https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	49	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W0Z5AEZTE7F4XY96KX0	https://interioricons.com/cdn/shop/files/2218-2_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	50	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W10R1Y3V0C3P56WCD8P	https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	51	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W10KBASE8CXG5VXSAKB	https://interioricons.com/cdn/shop/files/2727-1_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	52	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W10MP1H4GN8410D61RT	https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.824+00	2025-02-14 14:25:36.789+00	53	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2D2W10S6P3TD6ZZH53PA3M	https://interioricons.com/cdn/shop/files/5850-1_640x.jpg	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.825+00	2025-02-14 14:25:36.789+00	54	prod_01JM2D2W0CNQT5B7Y7ATY88HE7
img_01JM2K3ZRG879GBWSEKQ13JFEC	//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	0	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRGCF9XWD5VGVAHNV49	//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	1	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRG0XNJ6RK51SHHYP97	//interioricons.com/cdn/shop/files/4607-1.jpg?v=1721904360	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	2	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRGZYM6GF1N9SK9CW10	//interioricons.com/cdn/shop/files/4607-2.jpg?v=1721904360	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	3	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRGGA1PN1ZAEGCG3JKF	//interioricons.com/cdn/shop/files/4607-3.jpg?v=1721904360	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	4	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRGW7A136RGG817VQM0	//interioricons.com/cdn/shop/files/4607-4.jpg?v=1721904360	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	5	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRGNN5NATZ0B9ZG4NPH	//interioricons.com/cdn/shop/files/4607-5.jpg?v=1721904360	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	6	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRG1CZ4CJM2MJS89DF6	//interioricons.com/cdn/shop/files/4607-10.jpg?v=1721904361	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	7	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRG03QZK9EAX42D1N29	//interioricons.com/cdn/shop/files/4607-11.jpg?v=1721904360	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	8	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRGVKYNPW6WM2KG68D4	//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg?v=1722006767	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	9	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRH4PMABGJ3TTEMG88M	//interioricons.com/cdn/shop/files/4609-1.jpg?v=1721985320	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	10	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRHMGRR7C4D9KB7CHMM	//interioricons.com/cdn/shop/files/2341-1.jpg?v=1718797102	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	11	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRHGMV26RFX2HX8406Z	//interioricons.com/cdn/shop/files/2782-1.jpg?v=1716395618	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	12	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRHV6QCH8S9JDFDA68V	//interioricons.com/cdn/shop/files/4607-12.jpg?v=1722006767	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	13	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRHWXXDG1XNC6BR2E2G	//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	14	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRH2B2Q96FKYY219BY2	//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\n	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	15	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2K3ZRHXYTYS53F8TPW5E6P	//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\n	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	16	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH
img_01JM2E2AVEGQM7W3X17BJ0BM8X	https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	12	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE292YS2N3AJ0EEJRG	https://interioricons.com/cdn/shop/files/4607-10_640x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	13	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVED1793AK520VX08JB	https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	14	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVEVHJVVD40W7BE84WC	https://interioricons.com/cdn/shop/files/4607-11_640x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	15	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE7B7G7ZWWCEXT4BV0	https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	16	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVESNDSM3J8ETRA9G5H	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	17	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVERAJSVH01N492WYE5	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	18	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVEHAQ30P9FTE6KR5GA	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	19	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVEBGNPYKH6YCZJEJME	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	20	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE8NKBRZ0SF262EAYG	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	21	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE5X88M8BQBZMHP3SP	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	22	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE5T76RW0S3080PPJQ	https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	23	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE4QAG78Y34M2TDD4E	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	24	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVEFD963B1YAM14JNZQ	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	25	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVEA34Z7MTK3NWNSDW1	https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	26	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVECTH5KG10YVVCWJ76	https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	27	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2EME6VR1KEYPMDG7T8KH3H	https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	6	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6V8SS3M9J7CDPB6VAQ	https://interioricons.com/cdn/shop/files/4607-3_640x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	7	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2DKW7E46SM5AAQAXC3EYA3	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	0	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7EE2HTV8432ZCRFJ3N	https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	1	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2EME6VYDX99319258XRNEN	https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	8	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6VHG1KV9N88QSTC60P	https://interioricons.com/cdn/shop/files/4607-4_640x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	9	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6V13WHNAZG0QW5WN99	https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	10	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6VDKK158C7V66ETYA5	https://interioricons.com/cdn/shop/files/4607-5_640x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	11	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6VNJQ7N3T489ASKMDP	https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	12	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6V7RA8RP8APCT725PW	https://interioricons.com/cdn/shop/files/4607-10_640x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	13	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6VDEMH7EYX5D693YMA	https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	14	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6VZGT65KWKH8XJ6BJF	https://interioricons.com/cdn/shop/files/4607-11_640x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	15	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6W8PDHJTAMN81Q576P	https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	16	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WMB6XXN4DPS304J2H	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	17	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WQC1WTAMF7795NS1F	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	18	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6W46R2NF2G0XPVHJ2T	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	19	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6W2RHSK9QQQYC8QDTK	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	20	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WJ76XAGVFACKFZH7D	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	21	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2DKW7EDSHHFBZCT3MXC6GR	https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	2	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7EK6CC43V28KG46M3M	https://interioricons.com/cdn/shop/files/4607-1_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	3	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7E3VN49R7R3TA9QHZ1	https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	4	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FRJVMA4RMK7HD9R8R	https://interioricons.com/cdn/shop/files/4607-2_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	5	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FPYQAWABFYBAW3WK3	https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	6	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FJN77SDGV9HK4J743	https://interioricons.com/cdn/shop/files/4607-3_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	7	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FFBGJZ0TPYX8KCKMF	https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	8	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7F8YQRAYK348F04138	https://interioricons.com/cdn/shop/files/4607-4_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	9	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FYEZY9VE8QET3AKTJ	https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	10	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FAF3ZPG04QVG0NMBT	https://interioricons.com/cdn/shop/files/4607-5_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	11	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FNJRWABYPG7W34KVX	https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	12	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7F61F1EWNY7CSD51XG	https://interioricons.com/cdn/shop/files/4607-10_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	13	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FVENVVK09YC61S89Z	https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	14	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FG30C3FKN49EYGF7N	https://interioricons.com/cdn/shop/files/4607-11_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	15	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FH7PQ980BJKWSAWTN	https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	16	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FX0M3GZ2NDRRPK869	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	17	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7F95PRCG2PY8HRYM4K	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	18	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7F7BGD9QN2D31CJ1X1	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	19	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FYAFFBVQ1V11469GG	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	20	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FWC0M28SX0D8V8ZDW	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	21	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FEJ5CES7AX743JMXB	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	22	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7FFN19MKWS4F7FGG48	https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	23	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GC5CJEWDH94J647PK	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	24	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GQ294XJMM8PRVG23D	https://interioricons.com/cdn/shop/files/4607-1_60x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	25	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GK1FZTYBCX1Y8ZD6C	https://interioricons.com/cdn/shop/files/4607-2_60x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	26	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GNEJMJCKFGDQF4NWG	https://interioricons.com/cdn/shop/files/4607-3_60x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	27	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GHC0GSGMRG20ZR17N	https://interioricons.com/cdn/shop/files/4607-4_60x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	28	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7G88PS466FAWZRG4XP	https://interioricons.com/cdn/shop/files/4607-5_60x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	29	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GCBPBN72K1YN6CGWQ	https://interioricons.com/cdn/shop/files/4607-10_60x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	30	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GMZFP4D15NDPX003N	https://interioricons.com/cdn/shop/files/4607-11_60x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	31	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7G4DXP0TH7YPBMXYR4	https://interioricons.com/cdn/shop/files/4607-12_60x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	32	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GDVXBGNW7S6JTWSTA	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	33	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GYDJBEDCASKM7CYY2	https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	34	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GWSZY6YAD3EARVW0R	https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	35	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GTQADZAGR8SE81G1E	https://interioricons.com/cdn/shop/files/2184-1_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	36	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GAXHR18319036CEJK	https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	37	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GRWGJFBZTS9S36S89	https://interioricons.com/cdn/shop/files/2149-1_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	38	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GCR9TMR7NBPEWR73Z	https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	39	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GJ2MPAQ1YC274Y4MS	https://interioricons.com/cdn/shop/files/2028-1_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	40	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7G5WWRX6TKB6XE55TZ	https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00	41	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GR2A9DKJYJ382QTBJ	https://interioricons.com/cdn/shop/files/1635-1_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	42	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7GCASXEWRZ66GSCFTJ	https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	43	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7G6BPJG9W5AC7SGKHF	https://interioricons.com/cdn/shop/files/2333-2_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	44	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7G77XY4KHB5RQZWF3S	https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	45	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7H58RPMXYCN4KYA39C	https://interioricons.com/cdn/shop/files/1738-5_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	46	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7H4768PSN1N73ASS6F	https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	47	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7HW77YV8SBVB9ZEK94	https://interioricons.com/cdn/shop/files/1739-3_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	48	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7H1ZPQQMX5ZRFCE580	https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	49	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7H4N8AAHPQXSW24331	https://interioricons.com/cdn/shop/files/2218-2_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	50	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7HHCA6852N7FZ0Y98R	https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	51	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7HQ1FNMTQR97F9RNTH	https://interioricons.com/cdn/shop/files/2727-1_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	52	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7H83GX8MANMN8MM62J	https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	53	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2DKW7H4442AGFSWENCK98X	https://interioricons.com/cdn/shop/files/5850-1_640x.jpg	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.874+00	2025-02-14 14:30:35.84+00	54	prod_01JM2DKW6R5QPTQWZTFEPAZY5V
img_01JM2HTJ5R0WM536TVD1J8XPBB	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	21	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5RQHEQVSKH9J1DHC74	https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	22	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5RAK4J3GEA6TGR1Q52	https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	23	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2J0QDHA3M5R0NR74MX71VY	//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	0	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDHMX18CA7JS79YFX14	//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	1	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDHK4XDKEJ5VH8HHV15	//interioricons.com/cdn/shop/files/4607-1.jpg?v=1721904360	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	2	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDHA11BEMBEYS8GFB5Q	//interioricons.com/cdn/shop/files/4607-2.jpg?v=1721904360	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	3	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDHJ1PE6N0612331CGB	//interioricons.com/cdn/shop/files/4607-3.jpg?v=1721904360	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	4	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDHM8EBPQD0MGPMZ8AS	//interioricons.com/cdn/shop/files/4607-4.jpg?v=1721904360	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	5	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDHYNEXJY4A6H4040X4	//interioricons.com/cdn/shop/files/4607-5.jpg?v=1721904360	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	6	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDHS5GR28VT5SVC94HZ	//interioricons.com/cdn/shop/files/4607-10.jpg?v=1721904361	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	7	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDH79QXPYJTGFYP0YFX	//interioricons.com/cdn/shop/files/4607-11.jpg?v=1721904360	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	8	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2JCZZ4CJ8JC8F7S5PP0ZSC	//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	0	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ4158H51PC26TMJTNM	//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	1	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ4A28QVBDJ0QAFHC9N	//interioricons.com/cdn/shop/files/4607-1.jpg?v=1721904360	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	2	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2HTJ5Q85P8P996MKK1N1XE	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	0	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QCAF9GWK35HNPYPZX	https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	1	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5Q0HZZFF8HWEGHN2MF	https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	2	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5Q8BNSXQATRG40DDXR	https://interioricons.com/cdn/shop/files/4607-1_640x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	3	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QG9KBNSV0W0K04VDD	https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	4	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QH43BKT88E75S022A	https://interioricons.com/cdn/shop/files/4607-2_640x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	5	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QVHS8BXJVYEPKVWBD	https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	6	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5Q3WZZ1CM84ZB4431Z	https://interioricons.com/cdn/shop/files/4607-3_640x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	7	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QNCYRREX1PD41PNFH	https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	8	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QPH5MAWPSDKJKMV9W	https://interioricons.com/cdn/shop/files/4607-4_640x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	9	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QG1JWZ4XXPXZH6V8W	https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	10	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QNDGSYMR37WMKYJFM	https://interioricons.com/cdn/shop/files/4607-5_640x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	11	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2DWYHX0CHBABRBD9B08EDH	https://interioricons.com/cdn/shop/files/1635-1_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	34	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXWYCM0AEXQTBP7V0B	https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	35	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXHYXE42PC10C470WN	https://interioricons.com/cdn/shop/files/2333-2_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	36	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXDV81GD7PZT07HG4F	https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	37	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHX0B17EHZCC1AZGMHF	https://interioricons.com/cdn/shop/files/1738-5_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	38	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXSB323ZGSHS0ZM0SR	https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	39	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXJ6F9FQG44VAXHSPW	https://interioricons.com/cdn/shop/files/1739-3_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	40	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXP4EF6T0QRCRXW367	https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	41	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHXZ69GZ0ZY0F9727YC	https://interioricons.com/cdn/shop/files/2218-2_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	42	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHX2CEQ90QRYNP65TAD	https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	43	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHY9DRZMY2CAQ3958SF	https://interioricons.com/cdn/shop/files/2727-1_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	44	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHYXJ3Q42CSNRH96P1A	https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	45	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2DWYHY0R0R385AYKG08FRY	https://interioricons.com/cdn/shop/files/5850-1_640x.jpg	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.736+00	2025-02-14 14:33:33.708+00	46	prod_01JM2DWYH6WWGWX4SJYBCDP3ND
img_01JM2E2AVD6P05GATGXWBV8HM6	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.791+00	2025-02-14 14:43:26.757+00	0	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVDZBV2QE3PPQZ37RXW	https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	1	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVDJW9PPP4TYWQ258P4	https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	2	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVD9861W87TXQZ6PSYG	https://interioricons.com/cdn/shop/files/4607-1_640x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	3	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVDG4JRH98PC1W8M7S7	https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	4	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVDA5H2059PS31MTV7Q	https://interioricons.com/cdn/shop/files/4607-2_640x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	5	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVEPRY14VC6P7W5C227	https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	6	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE1FAFFQCGXP414KNJ	https://interioricons.com/cdn/shop/files/4607-3_640x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	7	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVEHQHAQKT5AJSAYTZ6	https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	8	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE606EKSTDR2QKMW1A	https://interioricons.com/cdn/shop/files/4607-4_640x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	9	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE5W0DPEVR42Y9DHC4	https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	10	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2E2AVE200PPPJB7TPYVH4K	https://interioricons.com/cdn/shop/files/4607-5_640x.jpg	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.792+00	2025-02-14 14:43:26.757+00	11	prod_01JM2E2AT36CVJX97E35K089W8
img_01JM2EME6VQ4AR0CXTXC7YFRA4	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	0	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6V3P0XSYH7XAS87KRM	https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	1	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6VE9QY8R7T1TV77X53	https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	2	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6V11BGCYXHJFVVC2TD	https://interioricons.com/cdn/shop/files/4607-1_640x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	3	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6VQCBPB54FKXW9ZGJQ	https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	4	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6VMNSH85GXGHSN5ETY	https://interioricons.com/cdn/shop/files/4607-2_640x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	5	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WW2H7AH8W0EBW4SJ8	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	22	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WFNAZ1G6NJS74K6QF	https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	23	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WE4GBN4PAS7RX7TQA	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	24	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WTD24STK8D82EF2N5	https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	25	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WJT78FMGEFZ7BY8V9	https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	26	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2EME6WVCHNYZP58B7N32G0	https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00	27	prod_01JM2EME6DXF5EBNHSCGDK6AR8
img_01JM2HQQ5M616V29W3HAJK6R2Y	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	0	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5MVEWA56ZXCE2B8X3G	https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	1	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5MQZ5F4V751GTTQGMP	https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	2	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5M05JY96YNSEE55V4X	https://interioricons.com/cdn/shop/files/4607-1_640x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	3	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NBYPQ4RTKQM860WKZ	https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	4	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NYG374DRTJ5QYJSGF	https://interioricons.com/cdn/shop/files/4607-2_640x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	5	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NEYE6ZV5XPCA4WB2E	https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	6	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NVNBYN1DCKCXZ1V3G	https://interioricons.com/cdn/shop/files/4607-3_640x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	7	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5NTNPPDC2D1DKDPDHE	https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	8	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HQQ5N25E7B7KG6B47DR0J	https://interioricons.com/cdn/shop/files/4607-4_640x.jpg	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00	9	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC
img_01JM2HTJ5QG2KRHK8PJDTKB1JF	https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	12	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5QATV701NSBMXN37P0	https://interioricons.com/cdn/shop/files/4607-10_640x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	13	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5RJPJWW9JX7MZHZCNN	https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	14	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5RAEKQVMTPCQ7GXHC1	https://interioricons.com/cdn/shop/files/4607-11_640x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	15	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5RN7CAESR9AKEWX1XG	https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	16	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5RC040X6KJSD6FDQ1E	https://interioricons.com/cdn/shop/files/4609-1_280x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	17	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5R9GDPTAMA03Y0VW92	https://interioricons.com/cdn/shop/files/2341-1_280x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	18	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5RAHDJQNGWPWW6H6BK	https://interioricons.com/cdn/shop/files/2782-1_280x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	19	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2HTJ5RTV16AE2ANNDHN0QW	https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00	20	prod_01JM2HTJ546FNVY2DCHXWX5R7V
img_01JM2J0QDH23DNWFCM0Z16B04E	//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg?v=1722006767	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	9	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDHNAZBDM78EVM35NW8	//interioricons.com/cdn/shop/files/4609-1.jpg?v=1721985320	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	10	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDH8ERQYDT70VMGFXG5	//interioricons.com/cdn/shop/files/2341-1.jpg?v=1718797102	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	11	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDJ2P9KJWR78Z0RB2V4	//interioricons.com/cdn/shop/files/2782-1.jpg?v=1716395618	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	12	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDJ17EW3TKH8CMNNWAH	//interioricons.com/cdn/shop/files/4607-12.jpg?v=1722006767	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	13	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDJGZVD82AAY1EAV659	//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	14	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDJXNTYGPYWDS0CAC7H	//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\n	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00	15	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2J0QDJRKQNT6SYE3YBRHE3	//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\n	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.239+00	2025-02-14 15:49:16.213+00	16	prod_01JM2J0QCVT5C2W5CE36Y8YVN3
img_01JM2JCZZ4Y6RZVZY2ZCK4T6NR	//interioricons.com/cdn/shop/files/4607-2.jpg?v=1721904360	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	3	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ571Q337HTZETA5Z4E	//interioricons.com/cdn/shop/files/4607-3.jpg?v=1721904360	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	4	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ5CZQE021XK4JXZ04X	//interioricons.com/cdn/shop/files/4607-4.jpg?v=1721904360	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	5	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ55FR82JRZHWD018J0	//interioricons.com/cdn/shop/files/4607-5.jpg?v=1721904360	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	6	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ5GFRE6J7TG4YPHN6F	//interioricons.com/cdn/shop/files/4607-10.jpg?v=1721904361	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	7	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ5RJ8DH2PC9Z10WAR1	//interioricons.com/cdn/shop/files/4607-11.jpg?v=1721904360	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	8	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ5Q9GZD0FC2XJ1X5FN	//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg?v=1722006767	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	9	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ52SXCENPEE0CCNXBX	//interioricons.com/cdn/shop/files/4609-1.jpg?v=1721985320	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	10	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ5BAF4B0SRG1X3C0XW	//interioricons.com/cdn/shop/files/2341-1.jpg?v=1718797102	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	11	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ51CXRQY0BB5CYVRHE	//interioricons.com/cdn/shop/files/2782-1.jpg?v=1716395618	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	12	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ573EZJ03K2HH70AVG	//interioricons.com/cdn/shop/files/4607-12.jpg?v=1722006767	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	13	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ51F3CA65DGRVHVGMJ	//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	14	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ53F1QW0167NZMZXRX	//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\n	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	15	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JCZZ51EXKC5JADHE8AYG0	//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\n	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00	16	prod_01JM2JCZYKS64JW7AHA5KDNWHY
img_01JM2JKYPSMZ7811Y1ZER7A29Y	//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	0	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPSZWB94BG71P68DQN8	//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	1	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPSB38SYMZSXMCB8WR3	//interioricons.com/cdn/shop/files/4607-1.jpg?v=1721904360	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	2	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPSKH6Y4DT060QBHC14	//interioricons.com/cdn/shop/files/4607-2.jpg?v=1721904360	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	3	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPSSC9N675REDS7EPPW	//interioricons.com/cdn/shop/files/4607-3.jpg?v=1721904360	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	4	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPSM3FZXRJ9HSFTGNY1	//interioricons.com/cdn/shop/files/4607-4.jpg?v=1721904360	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	5	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPTG09FYSN4WP48RX56	//interioricons.com/cdn/shop/files/4607-5.jpg?v=1721904360	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	6	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPT836VX3YQFWSJVFSD	//interioricons.com/cdn/shop/files/4607-10.jpg?v=1721904361	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	7	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPTM130JDRNC3YKVVBR	//interioricons.com/cdn/shop/files/4607-11.jpg?v=1721904360	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	8	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPTDH58GD3ZVPPV0Z1T	//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg?v=1722006767	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	9	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPT3Z6YD2PNMM3EQKEQ	//interioricons.com/cdn/shop/files/4609-1.jpg?v=1721985320	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	10	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPTS1YWTXH02JXKSXEA	//interioricons.com/cdn/shop/files/2341-1.jpg?v=1718797102	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	11	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPTKT47EQYFGSE2WN7C	//interioricons.com/cdn/shop/files/2782-1.jpg?v=1716395618	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	12	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPTM6Q8H78SXA19FSP8	//interioricons.com/cdn/shop/files/4607-12.jpg?v=1722006767	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	13	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPT9QVRJ8D0MA9F0FFP	//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	14	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPTEXCBN49BVJW5D65S	//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\n	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	15	prod_01JM2JKYPA276V6W1PMEFFTQCK
img_01JM2JKYPTMEBASKTX0JBNTN8V	//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\n	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00	16	prod_01JM2JKYPA276V6W1PMEFFTQCK
\.


--
-- Data for Name: inventory_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_item (id, created_at, updated_at, deleted_at, sku, origin_country, hs_code, mid_code, material, weight, length, height, width, requires_shipping, description, title, thumbnail, metadata) FROM stdin;
iitem_01JM18DSNXGVYGSFT40FYHFTWY	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHIRT-S-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	S / Black	S / Black	\N	\N
iitem_01JM18DSNX8DN8MRK5ABBNH427	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHIRT-S-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	S / White	S / White	\N	\N
iitem_01JM18DSNXWPGJ5E5AFAGDSVQ1	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHIRT-M-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	M / Black	M / Black	\N	\N
iitem_01JM18DSNXB1DPXN7DYPGJC496	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHIRT-M-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	M / White	M / White	\N	\N
iitem_01JM18DSNXDX2HJGQCZ2KRMKEB	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHIRT-L-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	L / Black	L / Black	\N	\N
iitem_01JM18DSNXPPR64514GA3NCXP2	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHIRT-L-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	L / White	L / White	\N	\N
iitem_01JM18DSNXXJHSK3910WCHE5X5	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHIRT-XL-BLACK	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / Black	XL / Black	\N	\N
iitem_01JM18DSNXZCQ4M0JMYN9KDQ08	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHIRT-XL-WHITE	\N	\N	\N	\N	\N	\N	\N	\N	t	XL / White	XL / White	\N	\N
iitem_01JM18DSNXNV1A9YJZ0VQN51HH	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SWEATSHIRT-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01JM18DSNX548SXS80XKZP70PG	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SWEATSHIRT-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01JM18DSNX0MR6QKFBWGYT74CS	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SWEATSHIRT-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01JM18DSNXCY2A425R2TEV06DK	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SWEATSHIRT-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01JM18DSNXDJ3DBKVRR98193Z5	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SWEATPANTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01JM18DSNXZSTM0CD4DQJBDER2	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SWEATPANTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01JM18DSNXV4H3VF5Z6W7288RF	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SWEATPANTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01JM18DSNXXAS1420HKS7W1P05	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SWEATPANTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01JM18DSNYQK5HYFNBS7HRHBSR	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHORTS-S	\N	\N	\N	\N	\N	\N	\N	\N	t	S	S	\N	\N
iitem_01JM18DSNYVHEN4FFM6W245XFV	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHORTS-M	\N	\N	\N	\N	\N	\N	\N	\N	t	M	M	\N	\N
iitem_01JM18DSNYQ0P1VJRV0JX0TCF8	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHORTS-L	\N	\N	\N	\N	\N	\N	\N	\N	t	L	L	\N	\N
iitem_01JM18DSNYYW8T348NPGE7JPS7	2025-02-14 03:35:50.206+00	2025-02-14 03:35:50.206+00	\N	SHORTS-XL	\N	\N	\N	\N	\N	\N	\N	\N	t	XL	XL	\N	\N
iitem_01JM1E0C1HPPDZNMSX9CFTFP4Z	2025-02-14 05:13:21.714+00	2025-02-14 05:14:37.588+00	2025-02-14 05:14:37.588+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth \n      Plinth Plinth - Black S	Plinth \n      Plinth Plinth - Black S	\N	\N
iitem_01JM1E0C1H288SKQ2PEHW3DVB5	2025-02-14 05:13:21.714+00	2025-02-14 05:14:37.596+00	2025-02-14 05:14:37.588+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth \n      Plinth Plinth - Black M	Plinth \n      Plinth Plinth - Black M	\N	\N
iitem_01JM1E0C1JYH4EFTJC2Y2ZWFJR	2025-02-14 05:13:21.714+00	2025-02-14 05:14:37.601+00	2025-02-14 05:14:37.588+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth \n      Plinth Plinth - Black L	Plinth \n      Plinth Plinth - Black L	\N	\N
iitem_01JM1E0C1JPCS89ESXKX9DDR7G	2025-02-14 05:13:21.714+00	2025-02-14 05:14:37.606+00	2025-02-14 05:14:37.588+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth \n      Plinth Plinth - Black XL	Plinth \n      Plinth Plinth - Black XL	\N	\N
iitem_01JM1E0C1JR6J4FAV5CH0J2WDW	2025-02-14 05:13:21.714+00	2025-02-14 05:14:37.612+00	2025-02-14 05:14:37.588+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth \n      Plinth Plinth - White S	Plinth \n      Plinth Plinth - White S	\N	\N
iitem_01JM1E0C1JCZPMBCVJJD2R9FYB	2025-02-14 05:13:21.714+00	2025-02-14 05:14:37.618+00	2025-02-14 05:14:37.588+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth \n      Plinth Plinth - White M	Plinth \n      Plinth Plinth - White M	\N	\N
iitem_01JM1E0C1JXMPQY6FZ5BSF0C7F	2025-02-14 05:13:21.714+00	2025-02-14 05:14:37.625+00	2025-02-14 05:14:37.588+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth \n      Plinth Plinth - White L	Plinth \n      Plinth Plinth - White L	\N	\N
iitem_01JM1E0C1J5FYBMZQQ22N8TQQ5	2025-02-14 05:13:21.714+00	2025-02-14 05:14:37.629+00	2025-02-14 05:14:37.588+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth \n      Plinth Plinth - White XL	Plinth \n      Plinth Plinth - White XL	\N	\N
iitem_01JM1X4XVR4254F1VTVJWTCSTW	2025-02-14 09:37:59.673+00	2025-02-14 09:44:51.625+00	2025-02-14 09:44:51.624+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM1X4XVRZCC06X1TNXD6S38M	2025-02-14 09:37:59.672+00	2025-02-14 09:44:51.633+00	2025-02-14 09:44:51.624+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM1X4XVRMMGK6433BBVGQMCX	2025-02-14 09:37:59.673+00	2025-02-14 09:44:51.638+00	2025-02-14 09:44:51.624+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM1X4XVRAF9DVT642KXH1HDK	2025-02-14 09:37:59.673+00	2025-02-14 09:44:51.642+00	2025-02-14 09:44:51.624+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM1X4XVRK97A5BGPCS10AFJC	2025-02-14 09:37:59.673+00	2025-02-14 09:44:51.647+00	2025-02-14 09:44:51.624+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM1XHT1FR4194QFR26T95ZVD	2025-02-14 09:45:01.743+00	2025-02-14 09:54:54.917+00	2025-02-14 09:54:54.916+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM1XHT1FKP74NGA6QX01F65N	2025-02-14 09:45:01.743+00	2025-02-14 09:54:54.927+00	2025-02-14 09:54:54.916+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM1XHT1FXQ65FQ1EX95JSZ0H	2025-02-14 09:45:01.743+00	2025-02-14 09:54:54.936+00	2025-02-14 09:54:54.916+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM1XHT1FWFCCD5EZR4HKT1DP	2025-02-14 09:45:01.743+00	2025-02-14 09:54:54.944+00	2025-02-14 09:54:54.916+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM1XHT1F20B5V23BRCJ9YR7K	2025-02-14 09:45:01.743+00	2025-02-14 09:54:54.95+00	2025-02-14 09:54:54.916+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM1Y66Z3CZXEE0NQEXKPA6RP	2025-02-14 09:56:10.34+00	2025-02-14 10:02:01.673+00	2025-02-14 10:02:01.671+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM1Y66Z3GPT1PP3QB0KZ2YNX	2025-02-14 09:56:10.34+00	2025-02-14 10:02:01.687+00	2025-02-14 10:02:01.671+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM1Y66Z39MJADGNM2G4PX5YG	2025-02-14 09:56:10.34+00	2025-02-14 10:02:01.696+00	2025-02-14 10:02:01.671+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM1Y66Z4EZ92MYYYWE6DWPDJ	2025-02-14 09:56:10.34+00	2025-02-14 10:02:01.703+00	2025-02-14 10:02:01.671+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM1Y66Z4BKDFEHY85RJD9YDA	2025-02-14 09:56:10.34+00	2025-02-14 10:02:01.709+00	2025-02-14 10:02:01.671+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM1YH98Q2G36XMBXD7J864R1	2025-02-14 10:02:13.143+00	2025-02-14 10:03:56.912+00	2025-02-14 10:03:56.911+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM1YH98QQ504TC6D9R1TG0SM	2025-02-14 10:02:13.143+00	2025-02-14 10:03:56.921+00	2025-02-14 10:03:56.911+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM1YH98QY213QQHDJXFH1K6F	2025-02-14 10:02:13.143+00	2025-02-14 10:03:56.926+00	2025-02-14 10:03:56.911+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM1YH98QK2YKS81JWDX6DWB5	2025-02-14 10:02:13.143+00	2025-02-14 10:03:56.932+00	2025-02-14 10:03:56.911+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM1YH98QJ8CF2P0ZG0ND9RVY	2025-02-14 10:02:13.143+00	2025-02-14 10:03:56.937+00	2025-02-14 10:03:56.911+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM1YPFW8E9S8R0YXF07534B9	2025-02-14 10:05:03.752+00	2025-02-14 10:20:30.466+00	2025-02-14 10:20:30.464+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM1YPFW8C3B84JKKHKVJYWG3	2025-02-14 10:05:03.753+00	2025-02-14 10:20:30.476+00	2025-02-14 10:20:30.464+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM1YPFW8BG75GFX5WKHKM3P0	2025-02-14 10:05:03.753+00	2025-02-14 10:20:30.482+00	2025-02-14 10:20:30.464+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM1YPFW8VEBQDYHQVSQX1KC8	2025-02-14 10:05:03.753+00	2025-02-14 10:20:30.489+00	2025-02-14 10:20:30.464+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM1YPFW8H1PSSAFA9YK4B3Q5	2025-02-14 10:05:03.753+00	2025-02-14 10:20:30.493+00	2025-02-14 10:20:30.464+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM1ZKBX10EYJDQBQM9095RSG	2025-02-14 10:20:49.954+00	2025-02-14 10:26:16.395+00	2025-02-14 10:26:16.394+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM1ZKBX159PKNK3DXWPMRXJQ	2025-02-14 10:20:49.954+00	2025-02-14 10:26:16.403+00	2025-02-14 10:26:16.394+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM1ZKBX12SJET483WQRZNCH1	2025-02-14 10:20:49.954+00	2025-02-14 10:26:16.411+00	2025-02-14 10:26:16.394+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM1ZKBX1FKFNS1K4QDYAR6Q7	2025-02-14 10:20:49.954+00	2025-02-14 10:26:16.42+00	2025-02-14 10:26:16.394+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM1ZKBX2387C4GCEKV9AS1YQ	2025-02-14 10:20:49.954+00	2025-02-14 10:26:16.426+00	2025-02-14 10:26:16.394+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM1ZXS8SAADWE3SX71F80BRY	2025-02-14 10:26:31.321+00	2025-02-14 10:32:00.139+00	2025-02-14 10:32:00.137+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM1ZXS8SY9ZBERWW7Q18M8M9	2025-02-14 10:26:31.322+00	2025-02-14 10:32:00.147+00	2025-02-14 10:32:00.137+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM1ZXS8S5AXSSAJJFFP5H0MY	2025-02-14 10:26:31.322+00	2025-02-14 10:32:00.153+00	2025-02-14 10:32:00.137+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM1ZXS8SW6WNVAT2NE0S331R	2025-02-14 10:26:31.322+00	2025-02-14 10:32:00.158+00	2025-02-14 10:32:00.137+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM1ZXS8SH6KQZNW8F2Q5NA5W	2025-02-14 10:26:31.322+00	2025-02-14 10:32:00.168+00	2025-02-14 10:32:00.137+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2BQZFQY5PG55C923QB8D61	2025-02-14 13:53:03.991+00	2025-02-14 14:02:46.59+00	2025-02-14 14:02:46.589+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM20CT0GZXCWX6KP0R9XW620	2025-02-14 10:34:43.6+00	2025-02-14 10:47:38.563+00	2025-02-14 10:47:38.562+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM20CT0G68F8SSPVST10P5TX	2025-02-14 10:34:43.6+00	2025-02-14 10:47:38.572+00	2025-02-14 10:47:38.562+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM20CT0GT704HMMCSN5CT3FB	2025-02-14 10:34:43.6+00	2025-02-14 10:47:38.576+00	2025-02-14 10:47:38.562+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM20CT0G8D6D14MDNK8WZ5HW	2025-02-14 10:34:43.6+00	2025-02-14 10:47:38.584+00	2025-02-14 10:47:38.562+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM20CT0GCH07YCGZB95JH33A	2025-02-14 10:34:43.601+00	2025-02-14 10:47:38.594+00	2025-02-14 10:47:38.562+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2C9Y33JT0687ZPKGW2915X	2025-02-14 14:02:52.387+00	2025-02-14 14:15:56.129+00	2025-02-14 14:15:56.128+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2C9Y334PTBNFA1P3YTAAKW	2025-02-14 14:02:52.387+00	2025-02-14 14:15:56.136+00	2025-02-14 14:15:56.128+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2C9Y336830JFM2KN1BK1XG	2025-02-14 14:02:52.387+00	2025-02-14 14:15:56.14+00	2025-02-14 14:15:56.128+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2C9Y33WE4BXM8Z4M4HH2FV	2025-02-14 14:02:52.387+00	2025-02-14 14:15:56.145+00	2025-02-14 14:15:56.128+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM214XJY3NJMQQ115JSP91R9	2025-02-14 10:47:53.694+00	2025-02-14 10:48:29.859+00	2025-02-14 10:48:29.858+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM214XJYGDYB5YXFZDS57BES	2025-02-14 10:47:53.694+00	2025-02-14 10:48:29.865+00	2025-02-14 10:48:29.858+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM214XJYTDSDC0AT5N4K3WN5	2025-02-14 10:47:53.694+00	2025-02-14 10:48:29.869+00	2025-02-14 10:48:29.858+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM214XJYS3C2SMHQA4S60STG	2025-02-14 10:47:53.694+00	2025-02-14 10:48:29.873+00	2025-02-14 10:48:29.858+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM214XJYKP07TF266ZZGECPX	2025-02-14 10:47:53.694+00	2025-02-14 10:48:29.877+00	2025-02-14 10:48:29.858+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2C9Y33G8531PVG1EKFT046	2025-02-14 14:02:52.387+00	2025-02-14 14:15:56.149+00	2025-02-14 14:15:56.128+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM216BTFYJVDX01FF49X4HS0	2025-02-14 10:48:41.039+00	2025-02-14 13:52:56.887+00	2025-02-14 13:52:56.886+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM216BTFS0HM6N7MZ5AG1C8F	2025-02-14 10:48:41.039+00	2025-02-14 13:52:56.895+00	2025-02-14 13:52:56.886+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM216BTFGF4268ERADXGSH5X	2025-02-14 10:48:41.039+00	2025-02-14 13:52:56.899+00	2025-02-14 13:52:56.886+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM216BTF91MFZ19M0G46EFEK	2025-02-14 10:48:41.039+00	2025-02-14 13:52:56.904+00	2025-02-14 13:52:56.886+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM216BTF7TEMBF9V1RCKWXAA	2025-02-14 10:48:41.039+00	2025-02-14 13:52:56.909+00	2025-02-14 13:52:56.886+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2D2W355HCTV9AX2RDSC6XB	2025-02-14 14:16:29.541+00	2025-02-14 14:25:36.742+00	2025-02-14 14:25:36.741+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2D2W359N2VVQCZ9ZRN1RP4	2025-02-14 14:16:29.541+00	2025-02-14 14:25:36.75+00	2025-02-14 14:25:36.741+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2D2W35P3ZYECSBXZYR0GAJ	2025-02-14 14:16:29.541+00	2025-02-14 14:25:36.756+00	2025-02-14 14:25:36.741+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2BQZFPZDJDCV7DEFTZ632M	2025-02-14 13:53:03.991+00	2025-02-14 13:54:50.764+00	2025-02-14 13:54:50.763+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2BQZFQPEYH6AF6CKDW6KAZ	2025-02-14 13:53:03.991+00	2025-02-14 13:54:50.773+00	2025-02-14 13:54:50.763+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2BQZFQS2VP7WQVZYKYTTYS	2025-02-14 13:53:03.991+00	2025-02-14 13:54:50.779+00	2025-02-14 13:54:50.763+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2BQZFQK30DMNQMBX092CTH	2025-02-14 13:53:03.991+00	2025-02-14 13:54:50.785+00	2025-02-14 13:54:50.763+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2D2W35FB8K029PZ8ZBZC7V	2025-02-14 14:16:29.541+00	2025-02-14 14:25:36.762+00	2025-02-14 14:25:36.741+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2D2W35SV9BTVFJ942M5AQQ	2025-02-14 14:16:29.541+00	2025-02-14 14:25:36.767+00	2025-02-14 14:25:36.741+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2DKW9KHWF8GKD0C5CD2NCY	2025-02-14 14:25:46.804+00	2025-02-14 14:30:35.778+00	2025-02-14 14:30:35.776+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2DKW9KN5NBJ00AR20GWDS2	2025-02-14 14:25:46.804+00	2025-02-14 14:30:35.791+00	2025-02-14 14:30:35.776+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2DKW9MBEG14Z6ZKJP8NCA6	2025-02-14 14:25:46.804+00	2025-02-14 14:30:35.798+00	2025-02-14 14:30:35.776+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2DKW9MD9KWGFEBM3RJJCYP	2025-02-14 14:25:46.804+00	2025-02-14 14:30:35.805+00	2025-02-14 14:30:35.776+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2DKW9MY1PSH38347ADANH7	2025-02-14 14:25:46.804+00	2025-02-14 14:30:35.811+00	2025-02-14 14:30:35.776+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2DWYKV99SQ90SH4PG2Y308	2025-02-14 14:30:44.091+00	2025-02-14 14:33:33.673+00	2025-02-14 14:33:33.672+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2DWYKV8RETZNG0QR42JZFQ	2025-02-14 14:30:44.091+00	2025-02-14 14:33:33.68+00	2025-02-14 14:33:33.672+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2DWYKVE3S3DDV6C42YN1DC	2025-02-14 14:30:44.091+00	2025-02-14 14:33:33.684+00	2025-02-14 14:33:33.672+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2DWYKVKEY68YN1P5WBA9ME	2025-02-14 14:30:44.091+00	2025-02-14 14:33:33.687+00	2025-02-14 14:33:33.672+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2DWYKV1YQ1T29HX1TE8MV9	2025-02-14 14:30:44.091+00	2025-02-14 14:33:33.691+00	2025-02-14 14:33:33.672+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2E2AWYMC3A8N4SD4AEVKNS	2025-02-14 14:33:40.511+00	2025-02-14 14:43:26.709+00	2025-02-14 14:43:26.708+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2E2AWYBR2NYQZ69P95TAD4	2025-02-14 14:33:40.511+00	2025-02-14 14:43:26.716+00	2025-02-14 14:43:26.708+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2E2AWYQM855DTCVBVRG0R5	2025-02-14 14:33:40.511+00	2025-02-14 14:43:26.721+00	2025-02-14 14:43:26.708+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2E2AWY75K2DHKVG9TENGSH	2025-02-14 14:33:40.511+00	2025-02-14 14:43:26.726+00	2025-02-14 14:43:26.708+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2E2AWYMG4X2T43JCED6P8J	2025-02-14 14:33:40.511+00	2025-02-14 14:43:26.73+00	2025-02-14 14:43:26.708+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2EME8ZP0N5KJJNBX5EXE87	2025-02-14 14:43:33.792+00	2025-02-14 15:36:51.536+00	2025-02-14 15:36:51.535+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2EME90DNF80Z97PC8A7JCN	2025-02-14 14:43:33.792+00	2025-02-14 15:36:51.546+00	2025-02-14 15:36:51.535+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2EME90RBF3EBBP581RSM57	2025-02-14 14:43:33.792+00	2025-02-14 15:36:51.553+00	2025-02-14 15:36:51.535+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2EME90F4RD3X1TV0RR0AYD	2025-02-14 14:43:33.792+00	2025-02-14 15:36:51.559+00	2025-02-14 15:36:51.535+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2EME906V1ST2ZJ3RXKT9WR	2025-02-14 14:43:33.792+00	2025-02-14 15:36:51.564+00	2025-02-14 15:36:51.535+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2HQQ8A75PFVHR3TZV8GS6M	2025-02-14 15:37:47.019+00	2025-02-14 15:39:13.425+00	2025-02-14 15:39:13.424+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2HQQ8ASG1CYCFBS0KF986R	2025-02-14 15:37:47.019+00	2025-02-14 15:39:13.432+00	2025-02-14 15:39:13.424+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2HQQ8A5GFDXC2EGCTG0PMA	2025-02-14 15:37:47.019+00	2025-02-14 15:39:13.437+00	2025-02-14 15:39:13.424+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2HQQ8A12EGRYXRSRH7H5H6	2025-02-14 15:37:47.019+00	2025-02-14 15:39:13.442+00	2025-02-14 15:39:13.424+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2HQQ8BGVK94Z04NDH2JRZE	2025-02-14 15:37:47.019+00	2025-02-14 15:39:13.447+00	2025-02-14 15:39:13.424+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2HTJ78E6G0E3CZYABGCRYN	2025-02-14 15:39:20.168+00	2025-02-14 15:42:36.471+00	2025-02-14 15:42:36.47+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2HTJ78XPQ45E4VP2EG97ZR	2025-02-14 15:39:20.168+00	2025-02-14 15:42:36.48+00	2025-02-14 15:42:36.47+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2HTJ783AH3J3DKAJ9WKPZ3	2025-02-14 15:39:20.168+00	2025-02-14 15:42:36.486+00	2025-02-14 15:42:36.47+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2HTJ78A16Y7MG5XWY599ES	2025-02-14 15:39:20.168+00	2025-02-14 15:42:36.493+00	2025-02-14 15:42:36.47+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2HTJ78V4XK9YC0T4AJN3FK	2025-02-14 15:39:20.168+00	2025-02-14 15:42:36.5+00	2025-02-14 15:42:36.47+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2J0QEY0J27PCVGB0SKBF82	2025-02-14 15:42:42.143+00	2025-02-14 15:49:16.149+00	2025-02-14 15:49:16.148+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2J0QEY9BWEWHMDJ5YY03NA	2025-02-14 15:42:42.143+00	2025-02-14 15:49:16.166+00	2025-02-14 15:49:16.148+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2J0QEZJBXM5XW73N534NXH	2025-02-14 15:42:42.143+00	2025-02-14 15:49:16.173+00	2025-02-14 15:49:16.148+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2J0QEZN78JCNEYNRJYGAF2	2025-02-14 15:42:42.143+00	2025-02-14 15:49:16.184+00	2025-02-14 15:49:16.148+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2J0QEZ95ZQYDF9N6597XRX	2025-02-14 15:42:42.143+00	2025-02-14 15:49:16.19+00	2025-02-14 15:49:16.148+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2JD00J7Q72RBD24MVWTJRG	2025-02-14 15:49:24.115+00	2025-02-14 15:52:47.539+00	2025-02-14 15:52:47.538+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2JD00J0H2F8ZBS0MSMZCBR	2025-02-14 15:49:24.115+00	2025-02-14 15:52:47.543+00	2025-02-14 15:52:47.538+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2JD00JZFT95CPBASZ1ZNDX	2025-02-14 15:49:24.115+00	2025-02-14 15:52:47.548+00	2025-02-14 15:52:47.538+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2JD00JN8GCCXDMVJ9DVXGB	2025-02-14 15:49:24.115+00	2025-02-14 15:52:47.553+00	2025-02-14 15:52:47.538+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2JD00JT3EDH22J1J21M41H	2025-02-14 15:49:24.114+00	2025-02-14 15:53:08.638+00	2025-02-14 15:53:08.638+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2JKYR1D280MHWBYP0T32QC	2025-02-14 15:53:12.193+00	2025-02-14 16:01:40.449+00	2025-02-14 16:01:40.448+00	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2JKYR1FVSV71SVFPMW6X55	2025-02-14 15:53:12.193+00	2025-02-14 16:01:40.462+00	2025-02-14 16:01:40.448+00	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2JKYR18816SBP88YN0PK72	2025-02-14 15:53:12.193+00	2025-02-14 16:01:40.467+00	2025-02-14 16:01:40.448+00	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2JKYR148N93899EBGT3F19	2025-02-14 15:53:12.193+00	2025-02-14 16:01:40.472+00	2025-02-14 16:01:40.448+00	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2JKYR14AQZEC7JWJ8PWS0T	2025-02-14 15:53:12.193+00	2025-02-14 16:01:40.482+00	2025-02-14 16:01:40.448+00	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
iitem_01JM2K3ZSSDCHZR98SV5AP5TMB	2025-02-14 16:01:57.561+00	2025-02-14 16:01:57.561+00	\N	2028	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Modellato Marble	Plinth - Modellato Marble	\N	\N
iitem_01JM2K3ZSSXYGDFSF4R8BESBP1	2025-02-14 16:01:57.561+00	2025-02-14 16:01:57.561+00	\N	1740	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - White Marble	Plinth - White Marble	\N	\N
iitem_01JM2K3ZSST54JVT6P1MZJM62J	2025-02-14 16:01:57.561+00	2025-02-14 16:01:57.561+00	\N	2606	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rosso Levanto Marble	Plinth - Rosso Levanto Marble	\N	\N
iitem_01JM2K3ZSSX77D2VYT8W4GQPF4	2025-02-14 16:01:57.561+00	2025-02-14 16:01:57.561+00	\N	4607	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Kunis Breccia	Plinth - Kunis Breccia	\N	\N
iitem_01JM2K3ZSSAEVFYR6S412HV3B0	2025-02-14 16:01:57.561+00	2025-02-14 16:01:57.561+00	\N	4608	\N	\N	\N	\N	\N	\N	\N	\N	t	Plinth - Rojo Alicante	Plinth - Rojo Alicante	\N	\N
\.


--
-- Data for Name: inventory_level; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.inventory_level (id, created_at, updated_at, deleted_at, inventory_item_id, location_id, stocked_quantity, reserved_quantity, incoming_quantity, metadata, raw_stocked_quantity, raw_reserved_quantity, raw_incoming_quantity) FROM stdin;
ilev_01JM18DSRT9ASFV6FY8DR1C37C	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNX0MR6QKFBWGYT74CS	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTXNV3XNRKG5T5YQZB	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNX548SXS80XKZP70PG	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTN3CC509CDM0T2RM4	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNX8DN8MRK5ABBNH427	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTHTV1BN99EYBRPZZZ	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXB1DPXN7DYPGJC496	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTMKYECYDRQBAMRY3P	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXCY2A425R2TEV06DK	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTNDHZQ82PTZRZ33RQ	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXDJ3DBKVRR98193Z5	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTTB4D9TM07F32J4BH	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXDX2HJGQCZ2KRMKEB	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRT0FF6EA96QBG2H31S	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXGVYGSFT40FYHFTWY	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRT0WBTQ9DX8QMANHRB	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXNV1A9YJZ0VQN51HH	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTM5T4BTVY8A4XY7NP	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXPPR64514GA3NCXP2	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRT2EY77S8KZK55NX4E	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXV4H3VF5Z6W7288RF	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTXCVQVR9M7KSR7PRB	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXWPGJ5E5AFAGDSVQ1	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTNDCEXB9F6TNWXVYK	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXXAS1420HKS7W1P05	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTYP3SPPBFVW4V94JB	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXXJHSK3910WCHE5X5	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRT8CH6HDDVPXZX66M0	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXZCQ4M0JMYN9KDQ08	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRT43JV65N0HP8T7PSP	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNXZSTM0CD4DQJBDER2	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRTMHS3Y0ZGSYX681TG	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNYQ0P1VJRV0JX0TCF8	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRT55VERJFBP05TF9QE	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNYQK5HYFNBS7HRHBSR	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRT9ZANKPGTM83G41QR	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNYVHEN4FFM6W245XFV	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
ilev_01JM18DSRV6K6H3ER8KYFDXE35	2025-02-14 03:35:50.299+00	2025-02-14 03:35:50.299+00	\N	iitem_01JM18DSNYYW8T348NPGE7JPS7	sloc_01JM18DSF42Z07ZVKW86JAM4XR	1000000	0	0	\N	{"value": "1000000", "precision": 20}	{"value": "0", "precision": 20}	{"value": "0", "precision": 20}
\.


--
-- Data for Name: invite; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.invite (id, email, accepted, token, expires_at, metadata, created_at, updated_at, deleted_at) FROM stdin;
invite_01JM18DQSG537RRPN641FM47BX	admin@medusa-test.com	f	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6Imludml0ZV8wMUpNMThEUVNHNTM3UlJQTjY0MUZNNDdCWCIsImVtYWlsIjoiYWRtaW5AbWVkdXNhLXRlc3QuY29tIiwiaWF0IjoxNzM5NTA0MTQ4LCJleHAiOjE3Mzk1OTA1NDgsImp0aSI6IjZiMmE2OGIzLTI0NWItNDIyZi04NDBlLTViOTNhMjBiZTg4ZSJ9.YfxyuAVP_Sxc2Qe-Ws1sgaDccAXM3PM0vyThIrrYALo	2025-02-15 03:35:48.272+00	\N	2025-02-14 03:35:48.273+00	2025-02-14 03:36:10.704+00	2025-02-14 03:36:10.704+00
\.


--
-- Data for Name: link_module_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.link_module_migrations (id, table_name, link_descriptor, created_at) FROM stdin;
1	cart_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "cart", "fromModule": "cart"}	2025-02-14 03:35:45.100634
2	cart_promotion	{"toModel": "promotions", "toModule": "promotion", "fromModel": "cart", "fromModule": "cart"}	2025-02-14 03:35:45.107041
3	location_fulfillment_set	{"toModel": "fulfillment_set", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2025-02-14 03:35:45.10847
4	location_fulfillment_provider	{"toModel": "fulfillment_provider", "toModule": "fulfillment", "fromModel": "location", "fromModule": "stock_location"}	2025-02-14 03:35:45.108583
5	order_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "order", "fromModule": "order"}	2025-02-14 03:35:45.109816
6	order_cart	{"toModel": "cart", "toModule": "cart", "fromModel": "order", "fromModule": "order"}	2025-02-14 03:35:45.109859
8	order_payment_collection	{"toModel": "payment_collection", "toModule": "payment", "fromModel": "order", "fromModule": "order"}	2025-02-14 03:35:45.10986
7	order_promotion	{"toModel": "promotion", "toModule": "promotion", "fromModel": "order", "fromModule": "order"}	2025-02-14 03:35:45.109973
9	product_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "product", "fromModule": "product"}	2025-02-14 03:35:45.110206
10	return_fulfillment	{"toModel": "fulfillments", "toModule": "fulfillment", "fromModel": "return", "fromModule": "order"}	2025-02-14 03:35:45.110207
11	product_variant_inventory_item	{"toModel": "inventory", "toModule": "inventory", "fromModel": "variant", "fromModule": "product"}	2025-02-14 03:35:45.111897
12	product_variant_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "variant", "fromModule": "product"}	2025-02-14 03:35:45.136671
13	publishable_api_key_sales_channel	{"toModel": "sales_channel", "toModule": "sales_channel", "fromModel": "api_key", "fromModule": "api_key"}	2025-02-14 03:35:45.140334
14	region_payment_provider	{"toModel": "payment_provider", "toModule": "payment", "fromModel": "region", "fromModule": "region"}	2025-02-14 03:35:45.140774
15	sales_channel_stock_location	{"toModel": "location", "toModule": "stock_location", "fromModel": "sales_channel", "fromModule": "sales_channel"}	2025-02-14 03:35:45.145956
16	shipping_option_price_set	{"toModel": "price_set", "toModule": "pricing", "fromModel": "shipping_option", "fromModule": "fulfillment"}	2025-02-14 03:35:45.146617
17	customer_account_holder	{"toModel": "account_holder", "toModule": "payment", "fromModel": "customer", "fromModule": "customer"}	2025-02-14 03:35:45.146717
18	product_shipping_profile	{"toModel": "shipping_profile", "toModule": "fulfillment", "fromModel": "product", "fromModule": "product"}	2025-02-14 03:35:45.14671
\.


--
-- Data for Name: location_fulfillment_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location_fulfillment_provider (stock_location_id, fulfillment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01JM18DSF42Z07ZVKW86JAM4XR	manual_manual	locfp_01JM18DSFAZNDF0YFX81G622C7	2025-02-14 03:35:49.993594+00	2025-02-14 03:35:49.993594+00	\N
\.


--
-- Data for Name: location_fulfillment_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.location_fulfillment_set (stock_location_id, fulfillment_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
sloc_01JM18DSF42Z07ZVKW86JAM4XR	fuset_01JM18DSFMAVM37G1C672XYWBZ	locfs_01JM18DSFWPKPEJCAPTPTTZEAM	2025-02-14 03:35:50.011579+00	2025-02-14 03:35:50.011579+00	\N
\.


--
-- Data for Name: mikro_orm_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mikro_orm_migrations (id, name, executed_at) FROM stdin;
1	Migration20231228143900	2025-02-14 03:35:43.023606+00
2	Migration20241206101446	2025-02-14 03:35:43.023606+00
3	Migration20250128174331	2025-02-14 03:35:43.023606+00
4	Migration20240307161216	2025-02-14 03:35:43.078232+00
5	Migration20241210073813	2025-02-14 03:35:43.078232+00
6	Migration20250106142624	2025-02-14 03:35:43.078232+00
7	Migration20250120110820	2025-02-14 03:35:43.078232+00
8	Migration20240307132720	2025-02-14 03:35:43.119442+00
9	Migration20240719123015	2025-02-14 03:35:43.119442+00
10	Migration20241213063611	2025-02-14 03:35:43.119442+00
11	InitialSetup20240401153642	2025-02-14 03:35:43.199831+00
12	Migration20240601111544	2025-02-14 03:35:43.199831+00
13	Migration202408271511	2025-02-14 03:35:43.199831+00
14	Migration20241122120331	2025-02-14 03:35:43.199831+00
15	Migration20241125090957	2025-02-14 03:35:43.199831+00
16	Migration20230929122253	2025-02-14 03:35:43.35504+00
17	Migration20240322094407	2025-02-14 03:35:43.35504+00
18	Migration20240322113359	2025-02-14 03:35:43.35504+00
19	Migration20240322120125	2025-02-14 03:35:43.35504+00
20	Migration20240626133555	2025-02-14 03:35:43.35504+00
21	Migration20240704094505	2025-02-14 03:35:43.35504+00
22	Migration20241127114534	2025-02-14 03:35:43.35504+00
23	Migration20241127223829	2025-02-14 03:35:43.35504+00
24	Migration20241128055359	2025-02-14 03:35:43.35504+00
25	Migration20241212190401	2025-02-14 03:35:43.35504+00
26	Migration20240227120221	2025-02-14 03:35:43.535476+00
27	Migration20240617102917	2025-02-14 03:35:43.535476+00
28	Migration20240624153824	2025-02-14 03:35:43.535476+00
29	Migration20241211061114	2025-02-14 03:35:43.535476+00
30	Migration20250113094144	2025-02-14 03:35:43.535476+00
31	Migration20250120110700	2025-02-14 03:35:43.535476+00
32	Migration20240124154000	2025-02-14 03:35:43.686638+00
33	Migration20240524123112	2025-02-14 03:35:43.686638+00
34	Migration20240602110946	2025-02-14 03:35:43.686638+00
35	Migration20241211074630	2025-02-14 03:35:43.686638+00
36	Migration20240115152146	2025-02-14 03:35:43.767072+00
37	Migration20240222170223	2025-02-14 03:35:43.794849+00
38	Migration20240831125857	2025-02-14 03:35:43.794849+00
39	Migration20241106085918	2025-02-14 03:35:43.794849+00
40	Migration20241205095237	2025-02-14 03:35:43.794849+00
41	Migration20241216183049	2025-02-14 03:35:43.794849+00
42	Migration20241218091938	2025-02-14 03:35:43.794849+00
43	Migration20250120115059	2025-02-14 03:35:43.794849+00
44	Migration20240205173216	2025-02-14 03:35:43.920124+00
45	Migration20240624200006	2025-02-14 03:35:43.920124+00
46	Migration20250120110744	2025-02-14 03:35:43.920124+00
47	InitialSetup20240221144943	2025-02-14 03:35:43.966367+00
48	Migration20240604080145	2025-02-14 03:35:43.966367+00
49	Migration20241205122700	2025-02-14 03:35:43.966367+00
50	InitialSetup20240227075933	2025-02-14 03:35:44.004963+00
51	Migration20240621145944	2025-02-14 03:35:44.004963+00
52	Migration20241206083313	2025-02-14 03:35:44.004963+00
53	Migration20240227090331	2025-02-14 03:35:44.038097+00
54	Migration20240710135844	2025-02-14 03:35:44.038097+00
55	Migration20240924114005	2025-02-14 03:35:44.038097+00
56	Migration20241212052837	2025-02-14 03:35:44.038097+00
57	InitialSetup20240228133303	2025-02-14 03:35:44.115299+00
58	Migration20240624082354	2025-02-14 03:35:44.115299+00
59	Migration20240225134525	2025-02-14 03:35:44.141315+00
60	Migration20240806072619	2025-02-14 03:35:44.141315+00
61	Migration20241211151053	2025-02-14 03:35:44.141315+00
62	Migration20250115160517	2025-02-14 03:35:44.141315+00
63	Migration20250120110552	2025-02-14 03:35:44.141315+00
64	Migration20250123122334	2025-02-14 03:35:44.141315+00
65	Migration20250206105639	2025-02-14 03:35:44.141315+00
66	Migration20250207132723	2025-02-14 03:35:44.141315+00
67	Migration20240219102530	2025-02-14 03:35:44.242999+00
68	Migration20240604100512	2025-02-14 03:35:44.242999+00
69	Migration20240715102100	2025-02-14 03:35:44.242999+00
70	Migration20240715174100	2025-02-14 03:35:44.242999+00
71	Migration20240716081800	2025-02-14 03:35:44.242999+00
72	Migration20240801085921	2025-02-14 03:35:44.242999+00
73	Migration20240821164505	2025-02-14 03:35:44.242999+00
74	Migration20240821170920	2025-02-14 03:35:44.242999+00
75	Migration20240827133639	2025-02-14 03:35:44.242999+00
76	Migration20240902195921	2025-02-14 03:35:44.242999+00
77	Migration20240913092514	2025-02-14 03:35:44.242999+00
78	Migration20240930122627	2025-02-14 03:35:44.242999+00
79	Migration20241014142943	2025-02-14 03:35:44.242999+00
80	Migration20241106085223	2025-02-14 03:35:44.242999+00
81	Migration20241129124827	2025-02-14 03:35:44.242999+00
82	Migration20241217162224	2025-02-14 03:35:44.242999+00
83	Migration20240205025928	2025-02-14 03:35:44.442527+00
84	Migration20240529080336	2025-02-14 03:35:44.442527+00
85	Migration20241202100304	2025-02-14 03:35:44.442527+00
86	Migration20240214033943	2025-02-14 03:35:44.505832+00
87	Migration20240703095850	2025-02-14 03:35:44.505832+00
88	Migration20241202103352	2025-02-14 03:35:44.505832+00
89	Migration20240311145700_InitialSetupMigration	2025-02-14 03:35:44.587481+00
90	Migration20240821170957	2025-02-14 03:35:44.587481+00
91	Migration20240917161003	2025-02-14 03:35:44.587481+00
92	Migration20241217110416	2025-02-14 03:35:44.587481+00
93	Migration20250113122235	2025-02-14 03:35:44.587481+00
94	Migration20250120115002	2025-02-14 03:35:44.587481+00
95	Migration20240509083918_InitialSetupMigration	2025-02-14 03:35:44.735012+00
96	Migration20240628075401	2025-02-14 03:35:44.735012+00
97	Migration20240830094712	2025-02-14 03:35:44.735012+00
98	Migration20250120110514	2025-02-14 03:35:44.735012+00
\.


--
-- Data for Name: notification; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification (id, "to", channel, template, data, trigger_type, resource_id, resource_type, receiver_id, original_notification_id, idempotency_key, external_id, provider_id, created_at, updated_at, deleted_at, status) FROM stdin;
noti_01JM2BX5DHKYGZE9MRF8C1AJKE		feed	admin-ui	{"file": {"url": "http://localhost:9000/static/private-1739541353898-1739541353894-product-exports.csv", "filename": "1739541353894-product-exports.csv", "mimeType": "text/csv"}, "title": "Product export", "description": "Product export completed successfully!"}	\N	\N	\N	\N	\N	\N	\N	local	2025-02-14 13:55:53.905+00	2025-02-14 13:55:53.915+00	\N	success
\.


--
-- Data for Name: notification_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notification_provider (id, handle, name, is_enabled, channels, created_at, updated_at, deleted_at) FROM stdin;
local	local	local	t	{feed}	2025-02-14 03:35:46.217+00	2025-02-14 03:35:46.217+00	\N
\.


--
-- Data for Name: order; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."order" (id, region_id, display_id, customer_id, version, sales_channel_id, status, is_draft_order, email, currency_code, shipping_address_id, billing_address_id, no_notification, metadata, created_at, updated_at, deleted_at, canceled_at) FROM stdin;
\.


--
-- Data for Name: order_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_address (id, customer_id, company, first_name, last_name, address_1, address_2, city, country_code, province, postal_code, phone, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_cart; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_cart (order_id, cart_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_change; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_change (id, order_id, version, description, status, internal_note, created_by, requested_by, requested_at, confirmed_by, confirmed_at, declined_by, declined_reason, metadata, declined_at, canceled_by, canceled_at, created_at, updated_at, change_type, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: order_change_action; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_change_action (id, order_id, version, ordering, order_change_id, reference, reference_id, action, details, amount, raw_amount, internal_note, applied, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: order_claim; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_claim (id, order_id, return_id, order_version, display_id, type, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_claim_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_claim_item (id, claim_id, item_id, is_additional_item, reason, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_claim_item_image; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_claim_item_image (id, claim_item_id, url, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_credit_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_credit_line (id, order_id, reference, reference_id, amount, raw_amount, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_exchange; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_exchange (id, order_id, return_id, order_version, display_id, no_notification, allow_backorder, difference_due, raw_difference_due, metadata, created_at, updated_at, deleted_at, canceled_at, created_by) FROM stdin;
\.


--
-- Data for Name: order_exchange_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_exchange_item (id, exchange_id, item_id, quantity, raw_quantity, note, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_fulfillment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_fulfillment (order_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_item (id, order_id, version, item_id, quantity, raw_quantity, fulfilled_quantity, raw_fulfilled_quantity, shipped_quantity, raw_shipped_quantity, return_requested_quantity, raw_return_requested_quantity, return_received_quantity, raw_return_received_quantity, return_dismissed_quantity, raw_return_dismissed_quantity, written_off_quantity, raw_written_off_quantity, metadata, created_at, updated_at, deleted_at, delivered_quantity, raw_delivered_quantity, unit_price, raw_unit_price, compare_at_unit_price, raw_compare_at_unit_price) FROM stdin;
\.


--
-- Data for Name: order_line_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_line_item (id, totals_id, title, subtitle, thumbnail, variant_id, product_id, product_title, product_description, product_subtitle, product_type, product_collection, product_handle, variant_sku, variant_barcode, variant_title, variant_option_values, requires_shipping, is_discountable, is_tax_inclusive, compare_at_unit_price, raw_compare_at_unit_price, unit_price, raw_unit_price, metadata, created_at, updated_at, deleted_at, is_custom_price, product_type_id) FROM stdin;
\.


--
-- Data for Name: order_line_item_adjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_line_item_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, item_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_line_item_tax_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_line_item_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, item_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_payment_collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_payment_collection (order_id, payment_collection_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_promotion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_promotion (order_id, promotion_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_shipping (id, order_id, version, shipping_method_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: order_shipping_method; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_shipping_method (id, name, description, amount, raw_amount, is_tax_inclusive, shipping_option_id, data, metadata, created_at, updated_at, deleted_at, is_custom_amount) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_adjustment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_shipping_method_adjustment (id, description, promotion_id, code, amount, raw_amount, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_shipping_method_tax_line; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_shipping_method_tax_line (id, description, tax_rate_id, code, rate, raw_rate, provider_id, created_at, updated_at, shipping_method_id, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_summary; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_summary (id, order_id, version, totals, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: order_transaction; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_transaction (id, order_id, version, amount, raw_amount, currency_code, reference, reference_id, created_at, updated_at, deleted_at, return_id, claim_id, exchange_id) FROM stdin;
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment (id, amount, raw_amount, currency_code, provider_id, data, created_at, updated_at, deleted_at, captured_at, canceled_at, payment_collection_id, payment_session_id, metadata) FROM stdin;
\.


--
-- Data for Name: payment_collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_collection (id, currency_code, amount, raw_amount, authorized_amount, raw_authorized_amount, captured_amount, raw_captured_amount, refunded_amount, raw_refunded_amount, created_at, updated_at, deleted_at, completed_at, status, metadata) FROM stdin;
\.


--
-- Data for Name: payment_collection_payment_providers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_collection_payment_providers (payment_collection_id, payment_provider_id) FROM stdin;
\.


--
-- Data for Name: payment_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
pp_system_default	t	2025-02-14 03:35:46.105+00	2025-02-14 03:35:46.105+00	\N
\.


--
-- Data for Name: payment_session; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payment_session (id, currency_code, amount, raw_amount, provider_id, data, context, status, authorized_at, payment_collection_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: price; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price (id, title, price_set_id, currency_code, raw_amount, rules_count, created_at, updated_at, deleted_at, price_list_id, amount, min_quantity, max_quantity) FROM stdin;
price_01JM18DSH1BZ3A9KAAM7YQ4QNG	\N	pset_01JM18DSH16AVHD8SRS6CCBZKD	usd	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N	\N	10	\N	\N
price_01JM18DSH1CVG9M5MEM889P8SX	\N	pset_01JM18DSH16AVHD8SRS6CCBZKD	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N	\N	10	\N	\N
price_01JM18DSH1FZQAPN9YF9G5R8KN	\N	pset_01JM18DSH16AVHD8SRS6CCBZKD	eur	{"value": "10", "precision": 20}	1	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N	\N	10	\N	\N
price_01JM18DSH1R12F40CP3RY8P6TQ	\N	pset_01JM18DSH1SEMHRMD26G6ZBAPH	usd	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N	\N	10	\N	\N
price_01JM18DSH1DNJ7ZFHNFM1Z1KQ7	\N	pset_01JM18DSH1SEMHRMD26G6ZBAPH	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N	\N	10	\N	\N
price_01JM18DSH1DTE04WWTKY37NSXF	\N	pset_01JM18DSH1SEMHRMD26G6ZBAPH	eur	{"value": "10", "precision": 20}	1	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N	\N	10	\N	\N
price_01JM18DSPM8VM7QG25QN673R30	\N	pset_01JM18DSPMNN4781DJBK624AFC	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPMFHK8VM4WT3A57VBV	\N	pset_01JM18DSPMNN4781DJBK624AFC	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPMHYCSD9BZ6KEC649X	\N	pset_01JM18DSPM0G8GD5X63F2QCPD6	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPMVWGJ4NENY4XQS3G9	\N	pset_01JM18DSPM0G8GD5X63F2QCPD6	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPNNVMM9MW5CFRRYDZJ	\N	pset_01JM18DSPNBX3QZ09BX64WN5WE	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPNAZ02G9V46945G81M	\N	pset_01JM18DSPNBX3QZ09BX64WN5WE	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPN19ZZTSP7K7RXVKPS	\N	pset_01JM18DSPNHG5PK2GYX1KCVEFQ	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPN85G5YKHKJC78F7SD	\N	pset_01JM18DSPNHG5PK2GYX1KCVEFQ	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPNFXQHW2Y053VFEF76	\N	pset_01JM18DSPNHZT2HCYXR0GHHCE7	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPNJ0H79SGPDGD4KYXN	\N	pset_01JM18DSPNHZT2HCYXR0GHHCE7	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPNQGP4D7R21X0ST8PP	\N	pset_01JM18DSPN60YD14JD9GAZDYKZ	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPN199E3NE5VZ58CWBX	\N	pset_01JM18DSPN60YD14JD9GAZDYKZ	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPN46CP8DA76N6A13WT	\N	pset_01JM18DSPNDVKAWR2NN6VV9DN9	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPNTJ7JWEF2NNJQT8WF	\N	pset_01JM18DSPNDVKAWR2NN6VV9DN9	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPN9NCSZ5N8Y61B3RAN	\N	pset_01JM18DSPNVRYZKSR06MYMN0JB	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPNY9VZGPGK5EBRMFF4	\N	pset_01JM18DSPNVRYZKSR06MYMN0JB	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPNPZX2268F6YT1RXBW	\N	pset_01JM18DSPPNAXZRZBRPF5E6459	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPNM39BFHPDK4ZTCHP3	\N	pset_01JM18DSPPNAXZRZBRPF5E6459	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPPXHZ8KAHKA1R6J6RP	\N	pset_01JM18DSPPS0FTRFWPDMXY6F42	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPPXF7FX7QDHCGPYC0D	\N	pset_01JM18DSPPS0FTRFWPDMXY6F42	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPP0KK085KPBFH1SABT	\N	pset_01JM18DSPPH222H6GV7T82E6H5	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPPPQE2TV82G1WBG17E	\N	pset_01JM18DSPPH222H6GV7T82E6H5	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPPZBGX2C4H0PDY7G3N	\N	pset_01JM18DSPPEY3PDR9C9HZ1KNNT	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPPMQ22EZ4VYDQ620Z3	\N	pset_01JM18DSPPEY3PDR9C9HZ1KNNT	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPP1VH18ZP9G6DYRE8N	\N	pset_01JM18DSPP6JY23PJBWHTEJ2XY	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPP902FRYMP8BA7ENS4	\N	pset_01JM18DSPP6JY23PJBWHTEJ2XY	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPP8W7DEX2VW74W7QTK	\N	pset_01JM18DSPP974MD6H7JZ7T2VGN	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPP1YBY11V4GZ887J3B	\N	pset_01JM18DSPP974MD6H7JZ7T2VGN	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPP9FRQQSFZQ27GV2WC	\N	pset_01JM18DSPPHYE768BJMY4SR8EK	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPPB4VZR0EETEMJMY6C	\N	pset_01JM18DSPPHYE768BJMY4SR8EK	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPPAGTB4WK5Z6MXDSGB	\N	pset_01JM18DSPP6X3FBRJQYX2YFC5P	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPPCMW9W1NMR1D8JP3C	\N	pset_01JM18DSPP6X3FBRJQYX2YFC5P	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPQQH1FJWD6E9E5690Y	\N	pset_01JM18DSPQ5YW3EDFKDZMKG4NN	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPQD7A2WB7DVK79HKMW	\N	pset_01JM18DSPQ5YW3EDFKDZMKG4NN	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPQHRGCW5A0E0GCSA9N	\N	pset_01JM18DSPQZ05H6WHGY1XFKMC7	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPQGPKYCPJHN8DWV2XC	\N	pset_01JM18DSPQZ05H6WHGY1XFKMC7	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPQ28E5VDAWAVR48GGQ	\N	pset_01JM18DSPQS5F2RKXKRK60NP67	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPQSDR38MP9PRWZYPGM	\N	pset_01JM18DSPQS5F2RKXKRK60NP67	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM18DSPQ5GPDP8WKNRJKAT8X	\N	pset_01JM18DSPQ1NF2T24SYCRQBWQC	eur	{"value": "10", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	10	\N	\N
price_01JM18DSPQ44H8AGEX6BT9B90G	\N	pset_01JM18DSPQ1NF2T24SYCRQBWQC	usd	{"value": "15", "precision": 20}	0	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N	\N	15	\N	\N
price_01JM1E0C2920FV6JDNX8VD6E8M	\N	pset_01JM1E0C29PGJ7E8CT5FF7AGV7	usd	{"value": "1000", "precision": 20}	0	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.68+00	2025-02-14 05:14:37.673+00	\N	1000	\N	\N
price_01JM1E0C294QZY5XJ6GAMEA5TF	\N	pset_01JM1E0C29TN72WG7G6FW4GFY8	usd	{"value": "1000", "precision": 20}	0	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.686+00	2025-02-14 05:14:37.673+00	\N	1000	\N	\N
price_01JM1E0C291CGX99DV8ATMQSY1	\N	pset_01JM1E0C29S4YNT1EH2NC77Q9P	usd	{"value": "1000", "precision": 20}	0	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.691+00	2025-02-14 05:14:37.673+00	\N	1000	\N	\N
price_01JM1E0C29EJ9QS6C0BEEBH4EQ	\N	pset_01JM1E0C294GGS646TQNVZN13B	usd	{"value": "1000", "precision": 20}	0	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.696+00	2025-02-14 05:14:37.673+00	\N	1000	\N	\N
price_01JM1E0C29QFM7FB1WH1J93ZAF	\N	pset_01JM1E0C29BY6K8WZH0MWP5V9S	usd	{"value": "1000", "precision": 20}	0	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.702+00	2025-02-14 05:14:37.673+00	\N	1000	\N	\N
price_01JM1E0C29ZB9MCWTTFN795NGE	\N	pset_01JM1E0C29GF7P000K459KQBW2	usd	{"value": "1000", "precision": 20}	0	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.708+00	2025-02-14 05:14:37.673+00	\N	1000	\N	\N
price_01JM1E0C296EFKQ3G0VFVM19GY	\N	pset_01JM1E0C29C2ECWBHNAKAGZCK9	usd	{"value": "1000", "precision": 20}	0	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.713+00	2025-02-14 05:14:37.673+00	\N	1000	\N	\N
price_01JM1E0C2A66JY8BHBJD5SX40X	\N	pset_01JM1E0C2A5Z95B4DE7R2EC0NS	usd	{"value": "1000", "precision": 20}	0	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.719+00	2025-02-14 05:14:37.673+00	\N	1000	\N	\N
price_01JM1X4XWFD8DZJB2M0VGC5HFY	\N	pset_01JM1X4XWFJ6SWFEC3XF038VXB	usd	{"value": "129900", "precision": 20}	0	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.684+00	2025-02-14 09:44:51.681+00	\N	129900	\N	\N
price_01JM1X4XWF1YC3FXDG94H2W2P9	\N	pset_01JM1X4XWFXJGW9VJE297N59D6	usd	{"value": "169900", "precision": 20}	0	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.691+00	2025-02-14 09:44:51.681+00	\N	169900	\N	\N
price_01JM1X4XWFZ42QZYQY3M0KEZ20	\N	pset_01JM1X4XWFCCA9DPBV7C1BJDYE	usd	{"value": "109900", "precision": 20}	0	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.696+00	2025-02-14 09:44:51.681+00	\N	109900	\N	\N
price_01JM1X4XWFVXDQSH3ST1YYV3VT	\N	pset_01JM1X4XWF82RR84G212KDA56B	usd	{"value": "209900", "precision": 20}	0	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.701+00	2025-02-14 09:44:51.681+00	\N	209900	\N	\N
price_01JM1X4XWFY1NWGKDAZB3QN5TY	\N	pset_01JM1X4XWF1E3PE0WJ951P5PPY	usd	{"value": "149900", "precision": 20}	0	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.706+00	2025-02-14 09:44:51.681+00	\N	149900	\N	\N
price_01JM1XHT23AXE9HKJBFC887JTM	\N	pset_01JM1XHT23Z9QNFQGC9RTXZAZJ	usd	{"value": "129900", "precision": 20}	0	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.005+00	2025-02-14 09:54:55.001+00	\N	129900	\N	\N
price_01JM1XHT238PXDK98460VEP2NF	\N	pset_01JM1XHT230N2TMJVCF5E20Z6S	usd	{"value": "169900", "precision": 20}	0	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.011+00	2025-02-14 09:54:55.001+00	\N	169900	\N	\N
price_01JM1XHT23WRX2JBFR8W9TB6DG	\N	pset_01JM1XHT2334FM2HPPBX2PMT40	usd	{"value": "109900", "precision": 20}	0	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.016+00	2025-02-14 09:54:55.001+00	\N	109900	\N	\N
price_01JM1XHT23DJ674BHERY9G55S9	\N	pset_01JM1XHT23V6CHMTNKAQMVESAK	usd	{"value": "209900", "precision": 20}	0	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.023+00	2025-02-14 09:54:55.001+00	\N	209900	\N	\N
price_01JM1XHT235FFYA5M7JY5Z2STK	\N	pset_01JM1XHT23KYB7XXDVS8DHWVJQ	usd	{"value": "149900", "precision": 20}	0	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.029+00	2025-02-14 09:54:55.001+00	\N	149900	\N	\N
price_01JM1Y66ZNMZVWHNX6RAWG3GYE	\N	pset_01JM1Y66ZPKMGGVQWM75M4TTMW	usd	{"value": "129900", "precision": 20}	0	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.753+00	2025-02-14 10:02:01.746+00	\N	129900	\N	\N
price_01JM1Y66ZPZ05S1P66YBPCHHTX	\N	pset_01JM1Y66ZP4E2NN8H5RMG40T2P	usd	{"value": "169900", "precision": 20}	0	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.759+00	2025-02-14 10:02:01.746+00	\N	169900	\N	\N
price_01JM1Y66ZPAQJYQQ41XCRZV1XX	\N	pset_01JM1Y66ZP3FCM3NW145J66XBZ	usd	{"value": "109900", "precision": 20}	0	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.763+00	2025-02-14 10:02:01.746+00	\N	109900	\N	\N
price_01JM1Y66ZPB846DA5HQ4AJSSFZ	\N	pset_01JM1Y66ZPSA3X8VP5N889ERZF	usd	{"value": "209900", "precision": 20}	0	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.768+00	2025-02-14 10:02:01.746+00	\N	209900	\N	\N
price_01JM1Y66ZPJVZN0KRKJX9BYXNR	\N	pset_01JM1Y66ZP45F1AMRR4W3QEJ6C	usd	{"value": "149900", "precision": 20}	0	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.773+00	2025-02-14 10:02:01.746+00	\N	149900	\N	\N
price_01JM1YH99K9GNZZPNTX44VBD5X	\N	pset_01JM1YH99MYXWVD92892YJA8BY	usd	{"value": "129900", "precision": 20}	0	2025-02-14 10:02:13.172+00	2025-02-14 10:03:56.984+00	2025-02-14 10:03:56.98+00	\N	129900	\N	\N
price_01JM1YH99M40X1TEVQ7KNEDE60	\N	pset_01JM1YH99MT1S24WDR0J3Q0HFS	usd	{"value": "169900", "precision": 20}	0	2025-02-14 10:02:13.172+00	2025-02-14 10:03:56.991+00	2025-02-14 10:03:56.98+00	\N	169900	\N	\N
price_01JM1YH99MAQG6E2XN1RAKY1SC	\N	pset_01JM1YH99MSJ4TNZ0A45JJ1ZP3	usd	{"value": "109900", "precision": 20}	0	2025-02-14 10:02:13.172+00	2025-02-14 10:03:56.996+00	2025-02-14 10:03:56.98+00	\N	109900	\N	\N
price_01JM1YH99MA59TQSVRF35HPVX1	\N	pset_01JM1YH99M5VEFB0FKDMXCZX50	usd	{"value": "209900", "precision": 20}	0	2025-02-14 10:02:13.172+00	2025-02-14 10:03:57+00	2025-02-14 10:03:56.98+00	\N	209900	\N	\N
price_01JM1YH99MC1D6QXKG67G52TQK	\N	pset_01JM1YH99MK3MRPP3FNAS5APW7	usd	{"value": "149900", "precision": 20}	0	2025-02-14 10:02:13.172+00	2025-02-14 10:03:57.005+00	2025-02-14 10:03:56.98+00	\N	149900	\N	\N
price_01JM2JD014VC66PDDV1VMF2P8C	\N	pset_01JM2JD014ZQB4NR5ZTC7PVKFJ	usd	{"value": "169900", "precision": 20}	0	2025-02-14 15:49:24.132+00	2025-02-14 15:52:47.6+00	2025-02-14 15:52:47.596+00	\N	169900	\N	\N
price_01JM1YPFWXXH2P7Y1XCGYEV7WW	\N	pset_01JM1YPFWX25W9MV145V5CWQ35	usd	{"value": "129900", "precision": 20}	0	2025-02-14 10:05:03.773+00	2025-02-14 10:20:30.538+00	2025-02-14 10:20:30.532+00	\N	129900	\N	\N
price_01JM1YPFWX04392FM4CYJAECBP	\N	pset_01JM1YPFWXAYTP03TNSQMCFXG1	usd	{"value": "169900", "precision": 20}	0	2025-02-14 10:05:03.774+00	2025-02-14 10:20:30.546+00	2025-02-14 10:20:30.532+00	\N	169900	\N	\N
price_01JM1YPFWXDGRAM7PSYCCB1PW4	\N	pset_01JM1YPFWXV3GVMJHH6XBMKKQC	usd	{"value": "109900", "precision": 20}	0	2025-02-14 10:05:03.774+00	2025-02-14 10:20:30.551+00	2025-02-14 10:20:30.532+00	\N	109900	\N	\N
price_01JM1YPFWXRHD36CVNYWH10YFH	\N	pset_01JM1YPFWXHZ699VS9RA49D9GQ	usd	{"value": "209900", "precision": 20}	0	2025-02-14 10:05:03.774+00	2025-02-14 10:20:30.557+00	2025-02-14 10:20:30.532+00	\N	209900	\N	\N
price_01JM1YPFWXQM5796XSZ2QHA1PG	\N	pset_01JM1YPFWXBQ8C802DKCF8M6RZ	usd	{"value": "149900", "precision": 20}	0	2025-02-14 10:05:03.774+00	2025-02-14 10:20:30.562+00	2025-02-14 10:20:30.532+00	\N	149900	\N	\N
price_01JM1ZKBXJ99NTDGZY8FK1WMBR	\N	pset_01JM1ZKBXJREJ0BXPN0CM0XES5	usd	{"value": "129900", "precision": 20}	0	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.481+00	2025-02-14 10:26:16.476+00	\N	129900	\N	\N
price_01JM1ZKBXJ9N8TJBNE5P3G03MP	\N	pset_01JM1ZKBXJGCANECFATGGB6CDZ	usd	{"value": "169900", "precision": 20}	0	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.489+00	2025-02-14 10:26:16.476+00	\N	169900	\N	\N
price_01JM1ZKBXJGA042KTP0QJGJND6	\N	pset_01JM1ZKBXJFRF2WAXEW9XSWE7S	usd	{"value": "109900", "precision": 20}	0	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.495+00	2025-02-14 10:26:16.476+00	\N	109900	\N	\N
price_01JM1ZKBXKRKSD538A1HY2R9XB	\N	pset_01JM1ZKBXK7HP6M133AWRGE67T	usd	{"value": "209900", "precision": 20}	0	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.501+00	2025-02-14 10:26:16.476+00	\N	209900	\N	\N
price_01JM1ZKBXK74K8TVBMTQXCPTJX	\N	pset_01JM1ZKBXK1KKB1FCBSJSWZNEJ	usd	{"value": "149900", "precision": 20}	0	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.506+00	2025-02-14 10:26:16.476+00	\N	149900	\N	\N
price_01JM2DWYMAG805GVMTF9X454NR	\N	pset_01JM2DWYMAMJ5XSSG95T9V6Z13	usd	{"value": "129900", "precision": 20}	0	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.726+00	2025-02-14 14:33:33.72+00	\N	129900	\N	\N
price_01JM2DWYMA6BZQPZMZCZ0Z5DM1	\N	pset_01JM2DWYMA1VS0FH5MYSVRX51V	usd	{"value": "169900", "precision": 20}	0	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.742+00	2025-02-14 14:33:33.72+00	\N	169900	\N	\N
price_01JM2DWYMA2RKSJ0C6FP8V1CP4	\N	pset_01JM2DWYMAGNM8H00H2KMGSS83	usd	{"value": "109900", "precision": 20}	0	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.747+00	2025-02-14 14:33:33.72+00	\N	109900	\N	\N
price_01JM2DWYMAFTE4W59CZ79H9S1P	\N	pset_01JM2DWYMAE4XVH3K80986598Q	usd	{"value": "209900", "precision": 20}	0	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.751+00	2025-02-14 14:33:33.72+00	\N	209900	\N	\N
price_01JM2DWYMAF1ZJGC66K8GNX02A	\N	pset_01JM2DWYMACQFHAYKSSWTDWQKT	usd	{"value": "149900", "precision": 20}	0	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.756+00	2025-02-14 14:33:33.72+00	\N	149900	\N	\N
price_01JM1ZXS9DSNG6A4WB990V7ZPT	\N	pset_01JM1ZXS9EBY1SEY1GMV2VBZ0Z	usd	{"value": "129900", "precision": 20}	0	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.263+00	2025-02-14 10:32:00.254+00	\N	129900	\N	\N
price_01JM1ZXS9EPF1RH7M4KSQ09GP0	\N	pset_01JM1ZXS9EW2YT1JMHPDXTTB30	usd	{"value": "169900", "precision": 20}	0	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.269+00	2025-02-14 10:32:00.254+00	\N	169900	\N	\N
price_01JM1ZXS9EDMYP36K0NGPJH1GP	\N	pset_01JM1ZXS9EH7F2TGGX3F3B4ET4	usd	{"value": "109900", "precision": 20}	0	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.274+00	2025-02-14 10:32:00.254+00	\N	109900	\N	\N
price_01JM1ZXS9E2558CSHNJ78M3N65	\N	pset_01JM1ZXS9E9KN9A9CCXJEQSZTC	usd	{"value": "209900", "precision": 20}	0	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.28+00	2025-02-14 10:32:00.254+00	\N	209900	\N	\N
price_01JM1ZXS9ESE8CYM65W48E4C5N	\N	pset_01JM1ZXS9ERZZ4QTW5WTRE1XMA	usd	{"value": "149900", "precision": 20}	0	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.287+00	2025-02-14 10:32:00.254+00	\N	149900	\N	\N
price_01JM20CT16X0PWNSB07MJER7PR	\N	pset_01JM20CT161RZQ0985N8PNDQE4	usd	{"value": "129900", "precision": 20}	0	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.665+00	2025-02-14 10:47:38.66+00	\N	129900	\N	\N
price_01JM20CT163TGKKKYK3ERMVBFR	\N	pset_01JM20CT161XC8G1S41CBSM1XQ	usd	{"value": "169900", "precision": 20}	0	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.672+00	2025-02-14 10:47:38.66+00	\N	169900	\N	\N
price_01JM20CT163G0S76QKVE942QJ6	\N	pset_01JM20CT16BSJTFXYF7HER4TMQ	usd	{"value": "109900", "precision": 20}	0	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.678+00	2025-02-14 10:47:38.66+00	\N	109900	\N	\N
price_01JM20CT17TA3EBPSCQAER5BS4	\N	pset_01JM20CT17A9SCDD1GPF4M3K65	usd	{"value": "209900", "precision": 20}	0	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.687+00	2025-02-14 10:47:38.66+00	\N	209900	\N	\N
price_01JM20CT17MVYHYBZ8CMEB3CST	\N	pset_01JM20CT17P1FFVAGTEAGEXMG2	usd	{"value": "149900", "precision": 20}	0	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.694+00	2025-02-14 10:47:38.66+00	\N	149900	\N	\N
price_01JM214XKJ841QG1FPKJ16SRCK	\N	pset_01JM214XKJVVR3WVX53E5SBN0P	usd	{"value": "129900", "precision": 20}	0	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.908+00	2025-02-14 10:48:29.902+00	\N	129900	\N	\N
price_01JM214XKJGYXTFBKK0T7HQMKG	\N	pset_01JM214XKJB6PF6H4CMGT0HBHP	usd	{"value": "169900", "precision": 20}	0	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.916+00	2025-02-14 10:48:29.902+00	\N	169900	\N	\N
price_01JM214XKJHCAKQW5QHNKGJASF	\N	pset_01JM214XKJ71Q9B4MDXS4DRNA9	usd	{"value": "109900", "precision": 20}	0	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.92+00	2025-02-14 10:48:29.902+00	\N	109900	\N	\N
price_01JM214XKJKTB283HJGCF04NJA	\N	pset_01JM214XKJDGN16P3MQAWZ3JX7	usd	{"value": "209900", "precision": 20}	0	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.924+00	2025-02-14 10:48:29.902+00	\N	209900	\N	\N
price_01JM214XKJRNXPRSZJTJS44KP9	\N	pset_01JM214XKJSGQN073K067E7QMV	usd	{"value": "149900", "precision": 20}	0	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.929+00	2025-02-14 10:48:29.902+00	\N	149900	\N	\N
price_01JM216BV3047MVGM4M2J5V9SK	\N	pset_01JM216BV3JZTGTSZ1H8WETD98	usd	{"value": "129900", "precision": 20}	0	2025-02-14 10:48:41.06+00	2025-02-14 13:52:56.956+00	2025-02-14 13:52:56.948+00	\N	129900	\N	\N
price_01JM216BV3XVN760C9CCRMJ7W8	\N	pset_01JM216BV3YDRZNZ1QTCHPW8DA	usd	{"value": "169900", "precision": 20}	0	2025-02-14 10:48:41.06+00	2025-02-14 13:52:56.964+00	2025-02-14 13:52:56.948+00	\N	169900	\N	\N
price_01JM216BV3PN3X2MZ88CYVCJMA	\N	pset_01JM216BV305GERKPDNFNK7AGZ	usd	{"value": "109900", "precision": 20}	0	2025-02-14 10:48:41.06+00	2025-02-14 13:52:56.969+00	2025-02-14 13:52:56.948+00	\N	109900	\N	\N
price_01JM216BV31TRHVZVJHWFP2GVK	\N	pset_01JM216BV3R4Y407J8GSBZ7F5P	usd	{"value": "209900", "precision": 20}	0	2025-02-14 10:48:41.06+00	2025-02-14 13:52:56.973+00	2025-02-14 13:52:56.948+00	\N	209900	\N	\N
price_01JM216BV3PCG4J2HBPF2AZV38	\N	pset_01JM216BV3KJW4F0MKQ5XHZ6XY	usd	{"value": "149900", "precision": 20}	0	2025-02-14 10:48:41.06+00	2025-02-14 13:52:56.978+00	2025-02-14 13:52:56.948+00	\N	149900	\N	\N
price_01JM2BQZGF0SSRFQ2P03H43R35	\N	pset_01JM2BQZGFGKS34F1CSV8K3JAB	usd	{"value": "149900", "precision": 20}	0	2025-02-14 13:53:04.016+00	2025-02-14 13:54:44.412+00	2025-02-14 13:54:44.401+00	\N	149900	\N	\N
price_01JM2BQZGF0553AD4PBX21QVA9	\N	pset_01JM2BQZGF5MJ6S1NGFAS87N63	usd	{"value": "129900", "precision": 20}	0	2025-02-14 13:53:04.015+00	2025-02-14 13:54:50.849+00	2025-02-14 13:54:50.843+00	\N	129900	\N	\N
price_01JM2BQZGFVHEYWDWTWTP8ETF9	\N	pset_01JM2BQZGFQMTMF5Q3RGD1ABV2	usd	{"value": "169900", "precision": 20}	0	2025-02-14 13:53:04.016+00	2025-02-14 13:54:50.854+00	2025-02-14 13:54:50.843+00	\N	169900	\N	\N
price_01JM2BQZGF9N79J19FNDEXMA7R	\N	pset_01JM2BQZGFN6M5MGTDJTMEWKSW	usd	{"value": "109900", "precision": 20}	0	2025-02-14 13:53:04.016+00	2025-02-14 13:54:50.859+00	2025-02-14 13:54:50.843+00	\N	109900	\N	\N
price_01JM2BQZGF4PGNVKFWCE7A004X	\N	pset_01JM2BQZGFSERRP34ES5BY0GRB	usd	{"value": "209900", "precision": 20}	0	2025-02-14 13:53:04.016+00	2025-02-14 13:54:50.865+00	2025-02-14 13:54:50.843+00	\N	209900	\N	\N
price_01JM2C9Y40PR20VBC4B0F9FHNR	\N	pset_01JM2C9Y40NVGNB52FGAED0DR2	usd	{"value": "129900", "precision": 20}	0	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.213+00	2025-02-14 14:15:56.203+00	\N	129900	\N	\N
price_01JM2C9Y400PG71150GNSADCS1	\N	pset_01JM2C9Y40BZEZSE0M25PFZR83	usd	{"value": "169900", "precision": 20}	0	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.239+00	2025-02-14 14:15:56.203+00	\N	169900	\N	\N
price_01JM2C9Y40KZMHDJA7KEBTM4R9	\N	pset_01JM2C9Y40YPCZJPM6VMR889AS	usd	{"value": "109900", "precision": 20}	0	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.244+00	2025-02-14 14:15:56.203+00	\N	109900	\N	\N
price_01JM2C9Y40TFB1G6J7GX3E1CAZ	\N	pset_01JM2C9Y4065D8YMNFRS7D4V9H	usd	{"value": "209900", "precision": 20}	0	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.248+00	2025-02-14 14:15:56.203+00	\N	209900	\N	\N
price_01JM2C9Y40VN6C3SZXMNQ85YCV	\N	pset_01JM2C9Y40S2JG2P484ZG74R84	usd	{"value": "149900", "precision": 20}	0	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.252+00	2025-02-14 14:15:56.203+00	\N	149900	\N	\N
price_01JM2D2W3PZT9MZZ83MPM51VE5	\N	pset_01JM2D2W3PJ9T4WVY10J762T9E	usd	{"value": "129900", "precision": 20}	0	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.812+00	2025-02-14 14:25:36.807+00	\N	129900	\N	\N
price_01JM2D2W3P9RHCEHEQP2PGFPYV	\N	pset_01JM2D2W3PHV8Z5CA7PZDP9RXV	usd	{"value": "169900", "precision": 20}	0	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.835+00	2025-02-14 14:25:36.807+00	\N	169900	\N	\N
price_01JM2D2W3PSC05QFT5SKQWAPKY	\N	pset_01JM2D2W3PDKS0CYE90JTW2305	usd	{"value": "109900", "precision": 20}	0	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.84+00	2025-02-14 14:25:36.807+00	\N	109900	\N	\N
price_01JM2D2W3PGVWZRKKCF0FHEY2G	\N	pset_01JM2D2W3PJKNN9DJ7HBNKYQDN	usd	{"value": "209900", "precision": 20}	0	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.845+00	2025-02-14 14:25:36.807+00	\N	209900	\N	\N
price_01JM2D2W3PH70K470ECW1EXJPE	\N	pset_01JM2D2W3PR4ZJTT8VSQ5GJG7X	usd	{"value": "149900", "precision": 20}	0	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.85+00	2025-02-14 14:25:36.807+00	\N	149900	\N	\N
price_01JM2DKWA16HB5MVW1CZJX38B1	\N	pset_01JM2DKWA1D9PTQYJYW9V40SMD	usd	{"value": "129900", "precision": 20}	0	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.86+00	2025-02-14 14:30:35.854+00	\N	129900	\N	\N
price_01JM2DKWA1RDE42SCK8C1HMVVG	\N	pset_01JM2DKWA1P20Z6H9J9NW9A65R	usd	{"value": "169900", "precision": 20}	0	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.878+00	2025-02-14 14:30:35.854+00	\N	169900	\N	\N
price_01JM2DKWA1YP0YG5D78J3WHZXD	\N	pset_01JM2DKWA1F4S5DW99V6R8M5QF	usd	{"value": "109900", "precision": 20}	0	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.884+00	2025-02-14 14:30:35.854+00	\N	109900	\N	\N
price_01JM2DKWA2QK104HAYNC2TC24K	\N	pset_01JM2DKWA21M4PWYQ560ZC9JZD	usd	{"value": "209900", "precision": 20}	0	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.888+00	2025-02-14 14:30:35.854+00	\N	209900	\N	\N
price_01JM2DKWA2JHBV82PMWXHR9JPY	\N	pset_01JM2DKWA233M1C1G1KXCX6FQH	usd	{"value": "149900", "precision": 20}	0	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.892+00	2025-02-14 14:30:35.854+00	\N	149900	\N	\N
price_01JM2E2AXD0FJ5P121HVCN017X	\N	pset_01JM2E2AXDQMHF62G3G6R10ZN8	usd	{"value": "129900", "precision": 20}	0	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.777+00	2025-02-14 14:43:26.771+00	\N	129900	\N	\N
price_01JM2E2AXDXY7FT3KXPQ4P35G4	\N	pset_01JM2E2AXDPP05VWZ0WQRW8WPS	usd	{"value": "169900", "precision": 20}	0	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.799+00	2025-02-14 14:43:26.771+00	\N	169900	\N	\N
price_01JM2E2AXEKTAGG1XC0D9MKTYG	\N	pset_01JM2E2AXES10KFMQ6N9F0ERE9	usd	{"value": "109900", "precision": 20}	0	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.807+00	2025-02-14 14:43:26.771+00	\N	109900	\N	\N
price_01JM2E2AXEAZNZQD5XWHQTH0K0	\N	pset_01JM2E2AXEWGDFJ0D7H4PH2AYP	usd	{"value": "209900", "precision": 20}	0	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.815+00	2025-02-14 14:43:26.771+00	\N	209900	\N	\N
price_01JM2E2AXENP4WHJ1AB2X6EPMK	\N	pset_01JM2E2AXE9SVWFCJAMGMJRGY9	usd	{"value": "149900", "precision": 20}	0	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.82+00	2025-02-14 14:43:26.771+00	\N	149900	\N	\N
price_01JM2EME9EFH1G7VBF4498RSMK	\N	pset_01JM2EME9EWCW4AW6CXW3YK4K2	usd	{"value": "129900", "precision": 20}	0	2025-02-14 14:43:33.807+00	2025-02-14 15:36:51.618+00	2025-02-14 15:36:51.611+00	\N	129900	\N	\N
price_01JM2EME9EPAHG185FM7Q8F83V	\N	pset_01JM2EME9E87QNQZVXMVF6ZQCT	usd	{"value": "169900", "precision": 20}	0	2025-02-14 14:43:33.807+00	2025-02-14 15:36:51.634+00	2025-02-14 15:36:51.611+00	\N	169900	\N	\N
price_01JM2EME9EK3HN4ASY0Z8Q6PKJ	\N	pset_01JM2EME9EZ3TRZFMP6163GF4A	usd	{"value": "109900", "precision": 20}	0	2025-02-14 14:43:33.807+00	2025-02-14 15:36:51.64+00	2025-02-14 15:36:51.611+00	\N	109900	\N	\N
price_01JM2EME9ER6N6A9KKY286P59S	\N	pset_01JM2EME9EZQQCXTXXXP9W4PVC	usd	{"value": "209900", "precision": 20}	0	2025-02-14 14:43:33.807+00	2025-02-14 15:36:51.645+00	2025-02-14 15:36:51.611+00	\N	209900	\N	\N
price_01JM2EME9E1254FQ1N6SDYBM72	\N	pset_01JM2EME9ERD3A7JGPVX0T7A09	usd	{"value": "149900", "precision": 20}	0	2025-02-14 14:43:33.807+00	2025-02-14 15:36:51.65+00	2025-02-14 15:36:51.611+00	\N	149900	\N	\N
price_01JM2HQQ9218XM5R03A5SSX57F	\N	pset_01JM2HQQ933CP5KX61XNEK2BDG	usd	{"value": "129900", "precision": 20}	0	2025-02-14 15:37:47.043+00	2025-02-14 15:39:13.483+00	2025-02-14 15:39:13.479+00	\N	129900	\N	\N
price_01JM2HQQ93NBYE7WX5WA86BWXG	\N	pset_01JM2HQQ93SYRZZEESZWXMY62F	usd	{"value": "169900", "precision": 20}	0	2025-02-14 15:37:47.044+00	2025-02-14 15:39:13.496+00	2025-02-14 15:39:13.479+00	\N	169900	\N	\N
price_01JM2HQQ93X2Q3QKXVXAX760P5	\N	pset_01JM2HQQ936342CA71GC89FPFN	usd	{"value": "109900", "precision": 20}	0	2025-02-14 15:37:47.044+00	2025-02-14 15:39:13.501+00	2025-02-14 15:39:13.479+00	\N	109900	\N	\N
price_01JM2HQQ93ZWG0W4Y55VHFKBRM	\N	pset_01JM2HQQ936J9KCSECC5SRG78R	usd	{"value": "209900", "precision": 20}	0	2025-02-14 15:37:47.044+00	2025-02-14 15:39:13.505+00	2025-02-14 15:39:13.479+00	\N	209900	\N	\N
price_01JM2HQQ93PZJ6AJCAGQSF8F80	\N	pset_01JM2HQQ937VK3GM58VB7KHW9M	usd	{"value": "149900", "precision": 20}	0	2025-02-14 15:37:47.044+00	2025-02-14 15:39:13.511+00	2025-02-14 15:39:13.479+00	\N	149900	\N	\N
price_01JM2HTJ7QV34MW37B8EN8SND9	\N	pset_01JM2HTJ7QR900WEWRMFAYENQK	usd	{"value": "129900", "precision": 20}	0	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.553+00	2025-02-14 15:42:36.548+00	\N	129900	\N	\N
price_01JM2HTJ7Q7TWFS3HH1FJ8KDS0	\N	pset_01JM2HTJ7RG4TBNB593GSN48AT	usd	{"value": "169900", "precision": 20}	0	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.564+00	2025-02-14 15:42:36.548+00	\N	169900	\N	\N
price_01JM2HTJ7R04V4EK9ZX9EE46J5	\N	pset_01JM2HTJ7RGWSRR2XA1C3TCEMR	usd	{"value": "109900", "precision": 20}	0	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.569+00	2025-02-14 15:42:36.548+00	\N	109900	\N	\N
price_01JM2HTJ7RRKEX3XYTFSYQEV11	\N	pset_01JM2HTJ7RBGVADYJ177NC0DSR	usd	{"value": "209900", "precision": 20}	0	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.573+00	2025-02-14 15:42:36.548+00	\N	209900	\N	\N
price_01JM2HTJ7R79S616JVBD8VQPQN	\N	pset_01JM2HTJ7RFF1YRQX8Z6VFT57T	usd	{"value": "149900", "precision": 20}	0	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.578+00	2025-02-14 15:42:36.548+00	\N	149900	\N	\N
price_01JM2J0QFD67R3XHSN60YFZ2S9	\N	pset_01JM2J0QFDRDFNWBE3GTQSHCBB	usd	{"value": "129900", "precision": 20}	0	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.231+00	2025-02-14 15:49:16.226+00	\N	129900	\N	\N
price_01JM2J0QFDB9VS8S9FP28FGX3V	\N	pset_01JM2J0QFD58ZSJNR50SRMQZFD	usd	{"value": "169900", "precision": 20}	0	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.245+00	2025-02-14 15:49:16.226+00	\N	169900	\N	\N
price_01JM2J0QFDBBKYFYBPW79YHWR9	\N	pset_01JM2J0QFDZAZP0E3PPQC3H8AP	usd	{"value": "109900", "precision": 20}	0	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.251+00	2025-02-14 15:49:16.226+00	\N	109900	\N	\N
price_01JM2J0QFD3T0PZJSM2YGRZER2	\N	pset_01JM2J0QFE9JRG8352R488K8J1	usd	{"value": "209900", "precision": 20}	0	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.257+00	2025-02-14 15:49:16.226+00	\N	209900	\N	\N
price_01JM2J0QFE2DJJ9028KPPJZ54Z	\N	pset_01JM2J0QFEXXPS40T2Q000GZVC	usd	{"value": "149900", "precision": 20}	0	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.264+00	2025-02-14 15:49:16.226+00	\N	149900	\N	\N
price_01JM2JD013RVJG66F38A6ESAPC	\N	pset_01JM2JD014XE4GMG5C8HA7BJT4	usd	{"value": "129900", "precision": 20}	0	2025-02-14 15:49:24.132+00	2025-02-14 15:52:43.027+00	2025-02-14 15:52:43.022+00	\N	129900	\N	\N
price_01JM2JD01403YE3G49Z4PC40Y9	\N	pset_01JM2JD0148VW1BT2MMFNFQ4K6	usd	{"value": "109900", "precision": 20}	0	2025-02-14 15:49:24.132+00	2025-02-14 15:52:47.61+00	2025-02-14 15:52:47.596+00	\N	109900	\N	\N
price_01JM2JD014W781DSQYMYFCR5YH	\N	pset_01JM2JD014AFCS0RZC9HPMHEZX	usd	{"value": "209900", "precision": 20}	0	2025-02-14 15:49:24.132+00	2025-02-14 15:52:47.614+00	2025-02-14 15:52:47.596+00	\N	209900	\N	\N
price_01JM2JD0142CDX1J7RN6YMGP3B	\N	pset_01JM2JD014SDA8KRR2MCB9NYG8	usd	{"value": "149900", "precision": 20}	0	2025-02-14 15:49:24.132+00	2025-02-14 15:52:47.619+00	2025-02-14 15:52:47.596+00	\N	149900	\N	\N
price_01JM2JKYRME0R3SM8HMH3TGYCX	\N	pset_01JM2JKYRMSZ8W0QR4XCDHG04X	usd	{"value": "129900", "precision": 20}	0	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.525+00	2025-02-14 16:01:40.521+00	\N	129900	\N	\N
price_01JM2JKYRMRN974ZVCXSQZAEA3	\N	pset_01JM2JKYRMJFJ3704WSEBAJC9C	usd	{"value": "169900", "precision": 20}	0	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.534+00	2025-02-14 16:01:40.521+00	\N	169900	\N	\N
price_01JM2JKYRMGV3B1DDV27611K7S	\N	pset_01JM2JKYRMS20PVQMQXHYQJPW9	usd	{"value": "109900", "precision": 20}	0	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.539+00	2025-02-14 16:01:40.521+00	\N	109900	\N	\N
price_01JM2JKYRM6VJQM4681X2CDNNN	\N	pset_01JM2JKYRMWNRBN1SYMA77BQNM	usd	{"value": "209900", "precision": 20}	0	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.544+00	2025-02-14 16:01:40.521+00	\N	209900	\N	\N
price_01JM2JKYRNQ6VWTS5G1VM4RNV7	\N	pset_01JM2JKYRNGP83N1PP02E2KQEQ	usd	{"value": "149900", "precision": 20}	0	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.549+00	2025-02-14 16:01:40.521+00	\N	149900	\N	\N
price_01JM2K3ZTAMW28JTV2RG6YV6R1	\N	pset_01JM2K3ZTA2Z4D9WQQCB4ADWVJ	usd	{"value": "129900", "precision": 20}	0	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N	\N	129900	\N	\N
price_01JM2K3ZTADSBXJJ1C1895S0KR	\N	pset_01JM2K3ZTASXNXFFF25J55ZTMH	usd	{"value": "169900", "precision": 20}	0	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N	\N	169900	\N	\N
price_01JM2K3ZTBSQF7ZEKX37FVA4FZ	\N	pset_01JM2K3ZTBH9A7KFAVKBJPB0PC	usd	{"value": "109900", "precision": 20}	0	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N	\N	109900	\N	\N
price_01JM2K3ZTBF5SNX9FC7FKFHFDV	\N	pset_01JM2K3ZTBEN1DRC46JZEJVE1H	usd	{"value": "209900", "precision": 20}	0	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N	\N	209900	\N	\N
price_01JM2K3ZTBB2MK6KWKNBF56374	\N	pset_01JM2K3ZTB1MQ2B34EJV4G6BEA	usd	{"value": "149900", "precision": 20}	0	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N	\N	149900	\N	\N
\.


--
-- Data for Name: price_list; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_list (id, status, starts_at, ends_at, rules_count, title, description, type, created_at, updated_at, deleted_at) FROM stdin;
plist_01JM1YCRNA1AVA96N78YBKM2XK	active	\N	\N	0	Promotion	zzzz	sale	2025-02-14 09:59:45.067+00	2025-02-14 09:59:45.067+00	\N
\.


--
-- Data for Name: price_list_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_list_rule (id, price_list_id, created_at, updated_at, deleted_at, value, attribute) FROM stdin;
\.


--
-- Data for Name: price_preference; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_preference (id, attribute, value, is_tax_inclusive, created_at, updated_at, deleted_at) FROM stdin;
prpref_01JM18DQS3MT0R56HCZ0MGNVCY	currency_code	eur	f	2025-02-14 03:35:48.259+00	2025-02-14 03:35:48.259+00	\N
prpref_01JM18DSDWFQ0KP9WKR33HKX22	currency_code	usd	f	2025-02-14 03:35:49.948+00	2025-02-14 03:35:49.948+00	\N
prpref_01JM18DSEHHS974234YVB5JTR8	region_id	reg_01JM18DSE1Q94XA80ZWJXQ58J3	f	2025-02-14 03:35:49.969+00	2025-02-14 03:35:49.969+00	\N
\.


--
-- Data for Name: price_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_rule (id, value, priority, price_id, created_at, updated_at, deleted_at, attribute, operator) FROM stdin;
prule_01JM18DSH1SFD01Q6JJAPB9RG0	reg_01JM18DSE1Q94XA80ZWJXQ58J3	0	price_01JM18DSH1FZQAPN9YF9G5R8KN	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N	region_id	eq
prule_01JM18DSH1T1V4PS983MS6YR79	reg_01JM18DSE1Q94XA80ZWJXQ58J3	0	price_01JM18DSH1DTE04WWTKY37NSXF	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N	region_id	eq
\.


--
-- Data for Name: price_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.price_set (id, created_at, updated_at, deleted_at) FROM stdin;
pset_01JM18DSH16AVHD8SRS6CCBZKD	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N
pset_01JM18DSH1SEMHRMD26G6ZBAPH	2025-02-14 03:35:50.05+00	2025-02-14 03:35:50.05+00	\N
pset_01JM18DSPMNN4781DJBK624AFC	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPM0G8GD5X63F2QCPD6	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPNBX3QZ09BX64WN5WE	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPNHG5PK2GYX1KCVEFQ	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPNHZT2HCYXR0GHHCE7	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPN60YD14JD9GAZDYKZ	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPNDVKAWR2NN6VV9DN9	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPNVRYZKSR06MYMN0JB	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPPNAXZRZBRPF5E6459	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPPS0FTRFWPDMXY6F42	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPPH222H6GV7T82E6H5	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPPEY3PDR9C9HZ1KNNT	2025-02-14 03:35:50.231+00	2025-02-14 03:35:50.231+00	\N
pset_01JM18DSPP6JY23PJBWHTEJ2XY	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N
pset_01JM18DSPP974MD6H7JZ7T2VGN	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N
pset_01JM18DSPPHYE768BJMY4SR8EK	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N
pset_01JM18DSPP6X3FBRJQYX2YFC5P	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N
pset_01JM18DSPQ5YW3EDFKDZMKG4NN	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N
pset_01JM18DSPQZ05H6WHGY1XFKMC7	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N
pset_01JM18DSPQS5F2RKXKRK60NP67	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N
pset_01JM18DSPQ1NF2T24SYCRQBWQC	2025-02-14 03:35:50.232+00	2025-02-14 03:35:50.232+00	\N
pset_01JM2D2W3PJ9T4WVY10J762T9E	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.807+00	2025-02-14 14:25:36.807+00
pset_01JM1E0C29PGJ7E8CT5FF7AGV7	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.674+00	2025-02-14 05:14:37.673+00
pset_01JM1E0C29TN72WG7G6FW4GFY8	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.684+00	2025-02-14 05:14:37.673+00
pset_01JM1E0C29S4YNT1EH2NC77Q9P	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.688+00	2025-02-14 05:14:37.673+00
pset_01JM1E0C294GGS646TQNVZN13B	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.694+00	2025-02-14 05:14:37.673+00
pset_01JM1E0C29BY6K8WZH0MWP5V9S	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.699+00	2025-02-14 05:14:37.673+00
pset_01JM1E0C29GF7P000K459KQBW2	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.705+00	2025-02-14 05:14:37.673+00
pset_01JM1E0C29C2ECWBHNAKAGZCK9	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.71+00	2025-02-14 05:14:37.673+00
pset_01JM1E0C2A5Z95B4DE7R2EC0NS	2025-02-14 05:13:21.738+00	2025-02-14 05:14:37.716+00	2025-02-14 05:14:37.673+00
pset_01JM1X4XWFJ6SWFEC3XF038VXB	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.681+00	2025-02-14 09:44:51.681+00
pset_01JM1X4XWFXJGW9VJE297N59D6	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.688+00	2025-02-14 09:44:51.681+00
pset_01JM1X4XWFCCA9DPBV7C1BJDYE	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.694+00	2025-02-14 09:44:51.681+00
pset_01JM1X4XWF82RR84G212KDA56B	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.698+00	2025-02-14 09:44:51.681+00
pset_01JM1X4XWF1E3PE0WJ951P5PPY	2025-02-14 09:37:59.696+00	2025-02-14 09:44:51.703+00	2025-02-14 09:44:51.681+00
pset_01JM1XHT23Z9QNFQGC9RTXZAZJ	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.001+00	2025-02-14 09:54:55.001+00
pset_01JM1XHT230N2TMJVCF5E20Z6S	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.009+00	2025-02-14 09:54:55.001+00
pset_01JM1XHT2334FM2HPPBX2PMT40	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.014+00	2025-02-14 09:54:55.001+00
pset_01JM1XHT23V6CHMTNKAQMVESAK	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.018+00	2025-02-14 09:54:55.001+00
pset_01JM1XHT23KYB7XXDVS8DHWVJQ	2025-02-14 09:45:01.763+00	2025-02-14 09:54:55.025+00	2025-02-14 09:54:55.001+00
pset_01JM1Y66ZPKMGGVQWM75M4TTMW	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.746+00	2025-02-14 10:02:01.746+00
pset_01JM1Y66ZP4E2NN8H5RMG40T2P	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.756+00	2025-02-14 10:02:01.746+00
pset_01JM1Y66ZP3FCM3NW145J66XBZ	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.761+00	2025-02-14 10:02:01.746+00
pset_01JM1Y66ZPSA3X8VP5N889ERZF	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.765+00	2025-02-14 10:02:01.746+00
pset_01JM1Y66ZP45F1AMRR4W3QEJ6C	2025-02-14 09:56:10.358+00	2025-02-14 10:02:01.77+00	2025-02-14 10:02:01.746+00
pset_01JM1YH99MYXWVD92892YJA8BY	2025-02-14 10:02:13.172+00	2025-02-14 10:03:56.98+00	2025-02-14 10:03:56.98+00
pset_01JM1YH99MT1S24WDR0J3Q0HFS	2025-02-14 10:02:13.172+00	2025-02-14 10:03:56.988+00	2025-02-14 10:03:56.98+00
pset_01JM1YH99MSJ4TNZ0A45JJ1ZP3	2025-02-14 10:02:13.172+00	2025-02-14 10:03:56.993+00	2025-02-14 10:03:56.98+00
pset_01JM1YH99M5VEFB0FKDMXCZX50	2025-02-14 10:02:13.172+00	2025-02-14 10:03:56.998+00	2025-02-14 10:03:56.98+00
pset_01JM1YH99MK3MRPP3FNAS5APW7	2025-02-14 10:02:13.172+00	2025-02-14 10:03:57.003+00	2025-02-14 10:03:56.98+00
pset_01JM1YPFWX25W9MV145V5CWQ35	2025-02-14 10:05:03.773+00	2025-02-14 10:20:30.532+00	2025-02-14 10:20:30.532+00
pset_01JM1YPFWXAYTP03TNSQMCFXG1	2025-02-14 10:05:03.773+00	2025-02-14 10:20:30.543+00	2025-02-14 10:20:30.532+00
pset_01JM1YPFWXV3GVMJHH6XBMKKQC	2025-02-14 10:05:03.773+00	2025-02-14 10:20:30.549+00	2025-02-14 10:20:30.532+00
pset_01JM1YPFWXHZ699VS9RA49D9GQ	2025-02-14 10:05:03.773+00	2025-02-14 10:20:30.554+00	2025-02-14 10:20:30.532+00
pset_01JM1YPFWXBQ8C802DKCF8M6RZ	2025-02-14 10:05:03.773+00	2025-02-14 10:20:30.559+00	2025-02-14 10:20:30.532+00
pset_01JM1ZKBXJREJ0BXPN0CM0XES5	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.476+00	2025-02-14 10:26:16.476+00
pset_01JM1ZKBXJGCANECFATGGB6CDZ	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.485+00	2025-02-14 10:26:16.476+00
pset_01JM1ZKBXJFRF2WAXEW9XSWE7S	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.491+00	2025-02-14 10:26:16.476+00
pset_01JM1ZKBXK7HP6M133AWRGE67T	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.498+00	2025-02-14 10:26:16.476+00
pset_01JM1ZKBXK1KKB1FCBSJSWZNEJ	2025-02-14 10:20:49.971+00	2025-02-14 10:26:16.504+00	2025-02-14 10:26:16.476+00
pset_01JM1ZXS9EBY1SEY1GMV2VBZ0Z	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.255+00	2025-02-14 10:32:00.254+00
pset_01JM1ZXS9EW2YT1JMHPDXTTB30	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.266+00	2025-02-14 10:32:00.254+00
pset_01JM1ZXS9EH7F2TGGX3F3B4ET4	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.271+00	2025-02-14 10:32:00.254+00
pset_01JM1ZXS9E9KN9A9CCXJEQSZTC	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.277+00	2025-02-14 10:32:00.254+00
pset_01JM1ZXS9ERZZ4QTW5WTRE1XMA	2025-02-14 10:26:31.342+00	2025-02-14 10:32:00.284+00	2025-02-14 10:32:00.254+00
pset_01JM20CT161RZQ0985N8PNDQE4	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.66+00	2025-02-14 10:47:38.66+00
pset_01JM20CT161XC8G1S41CBSM1XQ	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.669+00	2025-02-14 10:47:38.66+00
pset_01JM20CT16BSJTFXYF7HER4TMQ	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.676+00	2025-02-14 10:47:38.66+00
pset_01JM20CT17A9SCDD1GPF4M3K65	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.682+00	2025-02-14 10:47:38.66+00
pset_01JM20CT17P1FFVAGTEAGEXMG2	2025-02-14 10:34:43.623+00	2025-02-14 10:47:38.691+00	2025-02-14 10:47:38.66+00
pset_01JM214XKJVVR3WVX53E5SBN0P	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.903+00	2025-02-14 10:48:29.902+00
pset_01JM214XKJB6PF6H4CMGT0HBHP	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.913+00	2025-02-14 10:48:29.902+00
pset_01JM214XKJ71Q9B4MDXS4DRNA9	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.918+00	2025-02-14 10:48:29.902+00
pset_01JM214XKJDGN16P3MQAWZ3JX7	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.922+00	2025-02-14 10:48:29.902+00
pset_01JM214XKJSGQN073K067E7QMV	2025-02-14 10:47:53.715+00	2025-02-14 10:48:29.926+00	2025-02-14 10:48:29.902+00
pset_01JM216BV3JZTGTSZ1H8WETD98	2025-02-14 10:48:41.059+00	2025-02-14 13:52:56.948+00	2025-02-14 13:52:56.948+00
pset_01JM216BV3YDRZNZ1QTCHPW8DA	2025-02-14 10:48:41.059+00	2025-02-14 13:52:56.962+00	2025-02-14 13:52:56.948+00
pset_01JM216BV305GERKPDNFNK7AGZ	2025-02-14 10:48:41.059+00	2025-02-14 13:52:56.966+00	2025-02-14 13:52:56.948+00
pset_01JM216BV3R4Y407J8GSBZ7F5P	2025-02-14 10:48:41.059+00	2025-02-14 13:52:56.971+00	2025-02-14 13:52:56.948+00
pset_01JM216BV3KJW4F0MKQ5XHZ6XY	2025-02-14 10:48:41.059+00	2025-02-14 13:52:56.976+00	2025-02-14 13:52:56.948+00
pset_01JM2BQZGFGKS34F1CSV8K3JAB	2025-02-14 13:53:04.015+00	2025-02-14 13:54:44.402+00	2025-02-14 13:54:44.401+00
pset_01JM2BQZGF5MJ6S1NGFAS87N63	2025-02-14 13:53:04.015+00	2025-02-14 13:54:50.843+00	2025-02-14 13:54:50.843+00
pset_01JM2BQZGFQMTMF5Q3RGD1ABV2	2025-02-14 13:53:04.015+00	2025-02-14 13:54:50.852+00	2025-02-14 13:54:50.843+00
pset_01JM2BQZGFN6M5MGTDJTMEWKSW	2025-02-14 13:53:04.015+00	2025-02-14 13:54:50.857+00	2025-02-14 13:54:50.843+00
pset_01JM2BQZGFSERRP34ES5BY0GRB	2025-02-14 13:53:04.015+00	2025-02-14 13:54:50.862+00	2025-02-14 13:54:50.843+00
pset_01JM2C9Y40NVGNB52FGAED0DR2	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.203+00	2025-02-14 14:15:56.203+00
pset_01JM2C9Y40BZEZSE0M25PFZR83	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.232+00	2025-02-14 14:15:56.203+00
pset_01JM2C9Y40YPCZJPM6VMR889AS	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.241+00	2025-02-14 14:15:56.203+00
pset_01JM2C9Y4065D8YMNFRS7D4V9H	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.246+00	2025-02-14 14:15:56.203+00
pset_01JM2C9Y40S2JG2P484ZG74R84	2025-02-14 14:02:52.417+00	2025-02-14 14:15:56.251+00	2025-02-14 14:15:56.203+00
pset_01JM2D2W3PHV8Z5CA7PZDP9RXV	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.831+00	2025-02-14 14:25:36.807+00
pset_01JM2D2W3PDKS0CYE90JTW2305	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.838+00	2025-02-14 14:25:36.807+00
pset_01JM2D2W3PJKNN9DJ7HBNKYQDN	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.842+00	2025-02-14 14:25:36.807+00
pset_01JM2D2W3PR4ZJTT8VSQ5GJG7X	2025-02-14 14:16:29.558+00	2025-02-14 14:25:36.847+00	2025-02-14 14:25:36.807+00
pset_01JM2DKWA1D9PTQYJYW9V40SMD	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.854+00	2025-02-14 14:30:35.854+00
pset_01JM2DKWA1P20Z6H9J9NW9A65R	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.865+00	2025-02-14 14:30:35.854+00
pset_01JM2DKWA1F4S5DW99V6R8M5QF	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.881+00	2025-02-14 14:30:35.854+00
pset_01JM2DKWA21M4PWYQ560ZC9JZD	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.886+00	2025-02-14 14:30:35.854+00
pset_01JM2DKWA233M1C1G1KXCX6FQH	2025-02-14 14:25:46.818+00	2025-02-14 14:30:35.89+00	2025-02-14 14:30:35.854+00
pset_01JM2DWYMAMJ5XSSG95T9V6Z13	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.72+00	2025-02-14 14:33:33.72+00
pset_01JM2DWYMA1VS0FH5MYSVRX51V	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.738+00	2025-02-14 14:33:33.72+00
pset_01JM2DWYMAGNM8H00H2KMGSS83	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.745+00	2025-02-14 14:33:33.72+00
pset_01JM2DWYMAE4XVH3K80986598Q	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.749+00	2025-02-14 14:33:33.72+00
pset_01JM2DWYMACQFHAYKSSWTDWQKT	2025-02-14 14:30:44.106+00	2025-02-14 14:33:33.754+00	2025-02-14 14:33:33.72+00
pset_01JM2E2AXDQMHF62G3G6R10ZN8	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.772+00	2025-02-14 14:43:26.771+00
pset_01JM2E2AXDPP05VWZ0WQRW8WPS	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.794+00	2025-02-14 14:43:26.771+00
pset_01JM2E2AXES10KFMQ6N9F0ERE9	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.803+00	2025-02-14 14:43:26.771+00
pset_01JM2E2AXEWGDFJ0D7H4PH2AYP	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.81+00	2025-02-14 14:43:26.771+00
pset_01JM2E2AXE9SVWFCJAMGMJRGY9	2025-02-14 14:33:40.526+00	2025-02-14 14:43:26.818+00	2025-02-14 14:43:26.771+00
pset_01JM2EME9EWCW4AW6CXW3YK4K2	2025-02-14 14:43:33.806+00	2025-02-14 15:36:51.611+00	2025-02-14 15:36:51.611+00
pset_01JM2EME9E87QNQZVXMVF6ZQCT	2025-02-14 14:43:33.806+00	2025-02-14 15:36:51.63+00	2025-02-14 15:36:51.611+00
pset_01JM2EME9EZ3TRZFMP6163GF4A	2025-02-14 14:43:33.806+00	2025-02-14 15:36:51.638+00	2025-02-14 15:36:51.611+00
pset_01JM2EME9EZQQCXTXXXP9W4PVC	2025-02-14 14:43:33.806+00	2025-02-14 15:36:51.643+00	2025-02-14 15:36:51.611+00
pset_01JM2EME9ERD3A7JGPVX0T7A09	2025-02-14 14:43:33.806+00	2025-02-14 15:36:51.647+00	2025-02-14 15:36:51.611+00
pset_01JM2HQQ933CP5KX61XNEK2BDG	2025-02-14 15:37:47.043+00	2025-02-14 15:39:13.479+00	2025-02-14 15:39:13.479+00
pset_01JM2HQQ93SYRZZEESZWXMY62F	2025-02-14 15:37:47.043+00	2025-02-14 15:39:13.492+00	2025-02-14 15:39:13.479+00
pset_01JM2HQQ936342CA71GC89FPFN	2025-02-14 15:37:47.043+00	2025-02-14 15:39:13.499+00	2025-02-14 15:39:13.479+00
pset_01JM2HQQ936J9KCSECC5SRG78R	2025-02-14 15:37:47.043+00	2025-02-14 15:39:13.503+00	2025-02-14 15:39:13.479+00
pset_01JM2HQQ937VK3GM58VB7KHW9M	2025-02-14 15:37:47.043+00	2025-02-14 15:39:13.508+00	2025-02-14 15:39:13.479+00
pset_01JM2HTJ7QR900WEWRMFAYENQK	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.548+00	2025-02-14 15:42:36.548+00
pset_01JM2HTJ7RG4TBNB593GSN48AT	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.56+00	2025-02-14 15:42:36.548+00
pset_01JM2HTJ7RGWSRR2XA1C3TCEMR	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.566+00	2025-02-14 15:42:36.548+00
pset_01JM2HTJ7RBGVADYJ177NC0DSR	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.571+00	2025-02-14 15:42:36.548+00
pset_01JM2HTJ7RFF1YRQX8Z6VFT57T	2025-02-14 15:39:20.184+00	2025-02-14 15:42:36.575+00	2025-02-14 15:42:36.548+00
pset_01JM2J0QFDRDFNWBE3GTQSHCBB	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.226+00	2025-02-14 15:49:16.226+00
pset_01JM2J0QFD58ZSJNR50SRMQZFD	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.24+00	2025-02-14 15:49:16.226+00
pset_01JM2J0QFDZAZP0E3PPQC3H8AP	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.248+00	2025-02-14 15:49:16.226+00
pset_01JM2J0QFE9JRG8352R488K8J1	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.254+00	2025-02-14 15:49:16.226+00
pset_01JM2J0QFEXXPS40T2Q000GZVC	2025-02-14 15:42:42.158+00	2025-02-14 15:49:16.26+00	2025-02-14 15:49:16.226+00
pset_01JM2JD014XE4GMG5C8HA7BJT4	2025-02-14 15:49:24.132+00	2025-02-14 15:52:43.023+00	2025-02-14 15:52:43.022+00
pset_01JM2JD014ZQB4NR5ZTC7PVKFJ	2025-02-14 15:49:24.132+00	2025-02-14 15:52:47.596+00	2025-02-14 15:52:47.596+00
pset_01JM2JD0148VW1BT2MMFNFQ4K6	2025-02-14 15:49:24.132+00	2025-02-14 15:52:47.606+00	2025-02-14 15:52:47.596+00
pset_01JM2JD014AFCS0RZC9HPMHEZX	2025-02-14 15:49:24.132+00	2025-02-14 15:52:47.612+00	2025-02-14 15:52:47.596+00
pset_01JM2JD014SDA8KRR2MCB9NYG8	2025-02-14 15:49:24.132+00	2025-02-14 15:52:47.616+00	2025-02-14 15:52:47.596+00
pset_01JM2JKYRMSZ8W0QR4XCDHG04X	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.521+00	2025-02-14 16:01:40.521+00
pset_01JM2JKYRMJFJ3704WSEBAJC9C	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.532+00	2025-02-14 16:01:40.521+00
pset_01JM2JKYRMS20PVQMQXHYQJPW9	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.537+00	2025-02-14 16:01:40.521+00
pset_01JM2JKYRMWNRBN1SYMA77BQNM	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.542+00	2025-02-14 16:01:40.521+00
pset_01JM2JKYRNGP83N1PP02E2KQEQ	2025-02-14 15:53:12.213+00	2025-02-14 16:01:40.546+00	2025-02-14 16:01:40.521+00
pset_01JM2K3ZTA2Z4D9WQQCB4ADWVJ	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N
pset_01JM2K3ZTASXNXFFF25J55ZTMH	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N
pset_01JM2K3ZTBH9A7KFAVKBJPB0PC	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N
pset_01JM2K3ZTBEN1DRC46JZEJVE1H	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N
pset_01JM2K3ZTB1MQ2B34EJV4G6BEA	2025-02-14 16:01:57.579+00	2025-02-14 16:01:57.579+00	\N
\.


--
-- Data for Name: product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product (id, title, handle, subtitle, description, is_giftcard, status, thumbnail, weight, length, height, width, origin_country, hs_code, mid_code, material, collection_id, type_id, discountable, external_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
prod_01JM18DSK7TAY1V51GANPG18AV	Medusa T-Shirt	t-shirt	\N	Reimagine the feeling of a classic T-shirt. With our cotton T-shirts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/tee-black-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	\N
prod_01JM18DSK7W9Z90KJWFD1KCV2B	Medusa Sweatshirt	sweatshirt	\N	Reimagine the feeling of a classic sweatshirt. With our cotton sweatshirt, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatshirt-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	\N
prod_01JM18DSK7815R7Y7SR83MPR32	Medusa Sweatpants	sweatpants	\N	Reimagine the feeling of classic sweatpants. With our cotton sweatpants, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/sweatpants-gray-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	\N
prod_01JM18DSK77PEYBDSR2C19BESV	Medusa Shorts	shorts	\N	Reimagine the feeling of classic shorts. With our cotton shorts, everyday essentials no longer have to be ordinary.	f	published	https://medusa-public-images.s3.eu-west-1.amazonaws.com/shorts-vintage-front.png	400	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N	\N
prod_01JM1E0BZANZP61ADKJDGFNDDT	Plinth \n      Plinth Plinth	plinth-plinth-plinth	\N	No description available	f	published	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.65+00	2025-02-14 05:14:37.65+00	\N
prod_01JM1X4XS4ZK22S1J0RVAFVZ3D	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 09:37:59.570288+00	2025-02-14 09:44:51.667+00	2025-02-14 09:44:51.667+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM2JCZYKS64JW7AHA5KDNWHY	Plinth	plinth-indoor-outdoor-coffee-table-kunis-breccia	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	published	//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.584+00	2025-02-14 15:52:47.583+00	{"specifications": {}}
prod_01JM1XHSZPPZHYP21KAKY7GDXC	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 09:45:01.682795+00	2025-02-14 09:54:54.99+00	2025-02-14 09:54:54.989+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM1Y66XAHV0VX61YE1W723E0	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 09:56:10.275311+00	2025-02-14 10:02:01.73+00	2025-02-14 10:02:01.73+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM1YH96W1FT2HV43FS4A1XZ7	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 10:02:13.079697+00	2025-02-14 10:03:56.967+00	2025-02-14 10:03:56.967+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM1YPFTQQAHWNCNFP1G8FGZS	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 10:05:03.689478+00	2025-02-14 10:20:30.512+00	2025-02-14 10:20:30.512+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM2JKYPA276V6W1PMEFFTQCK	Plinth	plinth-indoor-outdoor-coffee-table-kunis-breccia	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	published	//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.509+00	2025-02-14 16:01:40.509+00	{"specifications": {}}
prod_01JM1ZKBV6FEBE1G34E5M7TDG6	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 10:20:49.888992+00	2025-02-14 10:26:16.462+00	2025-02-14 10:26:16.462+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM1ZXS73KBZRW0E30H8EM266	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 10:26:31.262457+00	2025-02-14 10:32:00.227+00	2025-02-14 10:32:00.227+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH	Plinth	plinth-indoor-outdoor-coffee-table-kunis-brecciarrrr	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	published	//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N	{"specifications": {}}
prod_01JM20CSYM758J4KV71BBPEXFZ	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 10:34:43.53264+00	2025-02-14 10:47:38.639+00	2025-02-14 10:47:38.639+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM214XH09Q6V6J76RJN70SWF	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 10:47:53.626332+00	2025-02-14 10:48:29.893+00	2025-02-14 10:48:29.893+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM216BRNW43T5W3PVRFQ3JQM	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 10:48:40.974869+00	2025-02-14 13:52:56.935+00	2025-02-14 13:52:56.935+00	{"subtitle": "Plinth Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM2BQZDYMD186EYYK52YZXXR	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 13:53:03.929393+00	2025-02-14 13:54:50.821+00	2025-02-14 13:54:50.821+00	{"subtitle": "Plinth Indoor/Outdoor Coffee Table, Kunis Breccia", "specifications": {}}
prod_01JM2C9Y1GFHME9JGCVMDW5QQJ	Plinth	plinth	\N	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 14:02:52.332391+00	2025-02-14 14:15:56.19+00	2025-02-14 14:15:56.19+00	{"specifications": {}}
prod_01JM2D2W0CNQT5B7Y7ATY88HE7	Plinth	plinth	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.79+00	2025-02-14 14:25:36.789+00	{"specifications": {}}
prod_01JM2DKW6R5QPTQWZTFEPAZY5V	Plinth	plinth	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.84+00	2025-02-14 14:30:35.84+00	{"specifications": {}}
prod_01JM2DWYH6WWGWX4SJYBCDP3ND	Plinth	plinth	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.709+00	2025-02-14 14:33:33.708+00	{"specifications": {}}
prod_01JM2E2AT36CVJX97E35K089W8	Plinth	plinth	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.758+00	2025-02-14 14:43:26.757+00	{"specifications": {}}
prod_01JM2EME6DXF5EBNHSCGDK6AR8	Plinth	plinth	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.\n                \n\t\t\t\t\t\t\tDesigned with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n\t\t\t\t\t\t\tThis item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.595+00	2025-02-14 15:36:51.594+00	{"specifications": {}}
prod_01JM2HQQ4VSP0SAZB0BSS7MSMC	Plinth	plinth-indoor-outdoor-coffee-table-kunis-breccia	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	draft	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.463+00	2025-02-14 15:39:13.463+00	{"specifications": {}}
prod_01JM2HTJ546FNVY2DCHXWX5R7V	Plinth	plinth-indoor-outdoor-coffee-table-kunis-breccia	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	published	https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.535+00	2025-02-14 15:42:36.535+00	{"specifications": {}}
prod_01JM2J0QCVT5C2W5CE36Y8YVN3	Plinth	plinth-indoor-outdoor-coffee-table-kunis-breccia	Plinth Indoor/Outdoor Coffee Table, Kunis Breccia	Designed with an intentionally modest silhouette, the Plinth coffee table sets out to elevate the natural beauty of marble in its purest form. A simple, unfussy profile allows the character of the stone to take center stage. Rejuvenating the traditional concept of a plinth, this contemporary Danish design reimagines the podium as not just a piece on which to display, but as an object d’art in itself. Made with elegant Kunis Breccia marble, expect each Plinth table to be unique, exhibiting subtle neutral veining, beautiful variations in color and charming distinctive characteristics.\n                    This item is not manufactured by or affiliated with the original designer(s) and associated parties. We do not claim any rights on any third party trademarks.	f	published	//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	t	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.214+00	2025-02-14 15:49:16.213+00	{"specifications": {}}
\.


--
-- Data for Name: product_category; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_category (id, name, description, handle, mpath, is_active, is_internal, rank, parent_category_id, created_at, updated_at, deleted_at, metadata) FROM stdin;
pcat_01JM18DSJFFJ6C086M3BNKQYSZ	Shirts		shirts	pcat_01JM18DSJFFJ6C086M3BNKQYSZ	t	f	0	\N	2025-02-14 03:35:50.098+00	2025-02-14 03:35:50.098+00	\N	\N
pcat_01JM18DSJFQFZEJWXDK1KDV86J	Sweatshirts		sweatshirts	pcat_01JM18DSJFQFZEJWXDK1KDV86J	t	f	1	\N	2025-02-14 03:35:50.098+00	2025-02-14 03:35:50.098+00	\N	\N
pcat_01JM18DSJGRDQXTCRAN69NRGD1	Pants		pants	pcat_01JM18DSJGRDQXTCRAN69NRGD1	t	f	2	\N	2025-02-14 03:35:50.098+00	2025-02-14 03:35:50.098+00	\N	\N
pcat_01JM18DSJHDFE4FDWBTXWZGC87	Merch		merch	pcat_01JM18DSJHDFE4FDWBTXWZGC87	t	f	3	\N	2025-02-14 03:35:50.098+00	2025-02-14 03:35:50.098+00	\N	\N
\.


--
-- Data for Name: product_category_product; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_category_product (product_id, product_category_id) FROM stdin;
prod_01JM18DSK7TAY1V51GANPG18AV	pcat_01JM18DSJFFJ6C086M3BNKQYSZ
prod_01JM18DSK7W9Z90KJWFD1KCV2B	pcat_01JM18DSJFQFZEJWXDK1KDV86J
prod_01JM18DSK7815R7Y7SR83MPR32	pcat_01JM18DSJGRDQXTCRAN69NRGD1
prod_01JM18DSK77PEYBDSR2C19BESV	pcat_01JM18DSJHDFE4FDWBTXWZGC87
\.


--
-- Data for Name: product_collection; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_collection (id, title, handle, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_option; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_option (id, title, product_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
opt_01JM18DSKKB1ANTGQ4GGFM7TN2	Size	prod_01JM18DSK7TAY1V51GANPG18AV	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
opt_01JM18DSKMR7E1TXXEC6HANWV8	Color	prod_01JM18DSK7TAY1V51GANPG18AV	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
opt_01JM18DSKMPEDCGVTK5KM4Z7Q8	Size	prod_01JM18DSK7W9Z90KJWFD1KCV2B	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
opt_01JM18DSKMFEDFQ08N8KM8FSF0	Size	prod_01JM18DSK7815R7Y7SR83MPR32	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
opt_01JM18DSKM9EK7KDN7NQ1Q4876	Size	prod_01JM18DSK77PEYBDSR2C19BESV	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
opt_01JM1E0BZE0PHJ5H5715PVTE9D	Color	prod_01JM1E0BZANZP61ADKJDGFNDDT	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.661+00	2025-02-14 05:14:37.65+00
opt_01JM1E0BZE576EEYRMW5ZPRJTC	Size	prod_01JM1E0BZANZP61ADKJDGFNDDT	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.667+00	2025-02-14 05:14:37.65+00
opt_01JM1X4XSCA6D1Z6YYFH1DJJBQ	Material	prod_01JM1X4XS4ZK22S1J0RVAFVZ3D	\N	2025-02-14 09:37:59.570288+00	2025-02-14 09:44:51.679+00	2025-02-14 09:44:51.667+00
opt_01JM1XHSZXCQM2RB02CT0KRVHS	Material	prod_01JM1XHSZPPZHYP21KAKY7GDXC	\N	2025-02-14 09:45:01.682795+00	2025-02-14 09:54:54.998+00	2025-02-14 09:54:54.989+00
opt_01JM1Y66XECS56QVVET8TVR84A	Material	prod_01JM1Y66XAHV0VX61YE1W723E0	\N	2025-02-14 09:56:10.275311+00	2025-02-14 10:02:01.743+00	2025-02-14 10:02:01.73+00
opt_01JM1YH9711BSMP9QYGNNRPNKN	Material	prod_01JM1YH96W1FT2HV43FS4A1XZ7	\N	2025-02-14 10:02:13.079697+00	2025-02-14 10:03:56.977+00	2025-02-14 10:03:56.967+00
opt_01JM1YPFTTX2R9RSB42MWXZPYC	Material	prod_01JM1YPFTQQAHWNCNFP1G8FGZS	\N	2025-02-14 10:05:03.689478+00	2025-02-14 10:20:30.527+00	2025-02-14 10:20:30.512+00
opt_01JM1ZKBVA75B5Q006AW44PY84	Material	prod_01JM1ZKBV6FEBE1G34E5M7TDG6	\N	2025-02-14 10:20:49.888992+00	2025-02-14 10:26:16.473+00	2025-02-14 10:26:16.462+00
opt_01JM1ZXS78JCW70RSMMJHPBTA5	Material	prod_01JM1ZXS73KBZRW0E30H8EM266	\N	2025-02-14 10:26:31.262457+00	2025-02-14 10:32:00.244+00	2025-02-14 10:32:00.227+00
opt_01JM20CSYRSD6Y20Z9T931KXS8	Material	prod_01JM20CSYM758J4KV71BBPEXFZ	\N	2025-02-14 10:34:43.53264+00	2025-02-14 10:47:38.657+00	2025-02-14 10:47:38.639+00
opt_01JM214XH5VN28J3G5JN056ZEB	Material	prod_01JM214XH09Q6V6J76RJN70SWF	\N	2025-02-14 10:47:53.626332+00	2025-02-14 10:48:29.902+00	2025-02-14 10:48:29.893+00
opt_01JM216BRTFTMDNNYQYY4SX5EX	Material	prod_01JM216BRNW43T5W3PVRFQ3JQM	\N	2025-02-14 10:48:40.974869+00	2025-02-14 13:52:56.946+00	2025-02-14 13:52:56.935+00
opt_01JM2BQZE65972NFKNPRY4Y4KJ	Material	prod_01JM2BQZDYMD186EYYK52YZXXR	\N	2025-02-14 13:53:03.929393+00	2025-02-14 13:54:50.836+00	2025-02-14 13:54:50.821+00
opt_01JM2C9Y1KGFTXHFNFNWE8VPRT	Material	prod_01JM2C9Y1GFHME9JGCVMDW5QQJ	\N	2025-02-14 14:02:52.332391+00	2025-02-14 14:15:56.207+00	2025-02-14 14:15:56.19+00
opt_01JM2D2W0HGWBSC6ZD346BJNGZ	Material	prod_01JM2D2W0CNQT5B7Y7ATY88HE7	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.805+00	2025-02-14 14:25:36.789+00
opt_01JM2DKW6Z0WVQV17NQ6WVPTHY	Material	prod_01JM2DKW6R5QPTQWZTFEPAZY5V	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.853+00	2025-02-14 14:30:35.84+00
opt_01JM2DWYHC9BP1T1YYZWPKA7GS	Material	prod_01JM2DWYH6WWGWX4SJYBCDP3ND	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.719+00	2025-02-14 14:33:33.708+00
opt_01JM2E2ATE61NCW3YD1V5G69MZ	Material	prod_01JM2E2AT36CVJX97E35K089W8	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.77+00	2025-02-14 14:43:26.757+00
opt_01JM2EME6GMKQ51ENPY60GBBM5	Material	prod_01JM2EME6DXF5EBNHSCGDK6AR8	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.61+00	2025-02-14 15:36:51.594+00
opt_01JM2HQQ52FFPQEZ33HR81AK30	Material	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.476+00	2025-02-14 15:39:13.463+00
opt_01JM2HTJ59QSHHY19REGTTT9S1	Material	prod_01JM2HTJ546FNVY2DCHXWX5R7V	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.547+00	2025-02-14 15:42:36.535+00
opt_01JM2J0QD6E1S9Y83M3EFF5PDK	Material	prod_01JM2J0QCVT5C2W5CE36Y8YVN3	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.225+00	2025-02-14 15:49:16.213+00
opt_01JM2JCZYRWJFBKD943A9VMDFH	Material	prod_01JM2JCZYKS64JW7AHA5KDNWHY	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.595+00	2025-02-14 15:52:47.583+00
opt_01JM2JKYPJHP2CXP1QNAX2GT64	Material	prod_01JM2JKYPA276V6W1PMEFFTQCK	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.519+00	2025-02-14 16:01:40.509+00
opt_01JM2K3ZQWT7F51VCRJPBTH8ZP	Material	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N
\.


--
-- Data for Name: product_option_value; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_option_value (id, value, option_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
optval_01JM18DSKRD544W38QG1B8EF51	S	opt_01JM18DSKKB1ANTGQ4GGFM7TN2	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKR8RJHBNZKMFFZVH7A	M	opt_01JM18DSKKB1ANTGQ4GGFM7TN2	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKR3Y5957BTE8RK3D7C	L	opt_01JM18DSKKB1ANTGQ4GGFM7TN2	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKRX5JJ8716R7R15H85	XL	opt_01JM18DSKKB1ANTGQ4GGFM7TN2	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKRB75NFEY9JCA55Y8K	Black	opt_01JM18DSKMR7E1TXXEC6HANWV8	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKR5FXZ5FYR6QZNAW8V	White	opt_01JM18DSKMR7E1TXXEC6HANWV8	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKS5C8KJFD7MGGSE30B	S	opt_01JM18DSKMPEDCGVTK5KM4Z7Q8	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKS6R37K78AR1QDPP6E	M	opt_01JM18DSKMPEDCGVTK5KM4Z7Q8	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKSDYC3DT1CR8G00NE8	L	opt_01JM18DSKMPEDCGVTK5KM4Z7Q8	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKSABVP7J3TGEQE4XE8	XL	opt_01JM18DSKMPEDCGVTK5KM4Z7Q8	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKTEPD5JP4YXZA5B251	S	opt_01JM18DSKMFEDFQ08N8KM8FSF0	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKTTQW3ZT7SGEEBD830	M	opt_01JM18DSKMFEDFQ08N8KM8FSF0	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKT0EM2S4S7PP4YXAPA	L	opt_01JM18DSKMFEDFQ08N8KM8FSF0	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKT4PDGHF49CDF2R6AC	XL	opt_01JM18DSKMFEDFQ08N8KM8FSF0	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKVZ6W1WG9Z11BFGKMX	S	opt_01JM18DSKM9EK7KDN7NQ1Q4876	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKV38Y57QGE1MTRZA6G	M	opt_01JM18DSKM9EK7KDN7NQ1Q4876	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKV86PGVBBJJYYYYND8	L	opt_01JM18DSKM9EK7KDN7NQ1Q4876	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM18DSKVC9WH2SX84QFH35KW	XL	opt_01JM18DSKM9EK7KDN7NQ1Q4876	\N	2025-02-14 03:35:50.107901+00	2025-02-14 03:35:50.107901+00	\N
optval_01JM2K3ZR3HVF329S87KVF9BRS	Modellato Marble	opt_01JM2K3ZQWT7F51VCRJPBTH8ZP	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N
optval_01JM2K3ZR3BJW48ADCABRYMGZE	White Marble	opt_01JM2K3ZQWT7F51VCRJPBTH8ZP	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N
optval_01JM2K3ZR3PT9259ETR3XS62KF	Rosso Levanto Marble	opt_01JM2K3ZQWT7F51VCRJPBTH8ZP	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N
optval_01JM2K3ZR3HQ6QF8N7AJFYV5CE	Kunis Breccia	opt_01JM2K3ZQWT7F51VCRJPBTH8ZP	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N
optval_01JM2K3ZR3EGE48P5XTWDJGYCG	Rojo Alicante	opt_01JM2K3ZQWT7F51VCRJPBTH8ZP	\N	2025-02-14 16:01:57.469254+00	2025-02-14 16:01:57.469254+00	\N
optval_01JM1E0BZJ1HKFSV5DFCGZQZHJ	Black	opt_01JM1E0BZE0PHJ5H5715PVTE9D	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.667+00	2025-02-14 05:14:37.65+00
optval_01JM1E0BZJN0873EW23WC8X0CG	White	opt_01JM1E0BZE0PHJ5H5715PVTE9D	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.667+00	2025-02-14 05:14:37.65+00
optval_01JM1E0BZJKAYX58KM6MXKRJJZ	S	opt_01JM1E0BZE576EEYRMW5ZPRJTC	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.678+00	2025-02-14 05:14:37.65+00
optval_01JM1E0BZJKJP46PBKYH7R5KZF	M	opt_01JM1E0BZE576EEYRMW5ZPRJTC	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.678+00	2025-02-14 05:14:37.65+00
optval_01JM1E0BZJBY823Z6CEVZGA6NX	L	opt_01JM1E0BZE576EEYRMW5ZPRJTC	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.678+00	2025-02-14 05:14:37.65+00
optval_01JM1E0BZJS8DAEGA2063NM8AH	XL	opt_01JM1E0BZE576EEYRMW5ZPRJTC	\N	2025-02-14 05:13:21.635675+00	2025-02-14 05:14:37.679+00	2025-02-14 05:14:37.65+00
optval_01JM1X4XSFXSA1EYG4APSRJ22M	Modellato Marble	opt_01JM1X4XSCA6D1Z6YYFH1DJJBQ	\N	2025-02-14 09:37:59.570288+00	2025-02-14 09:44:51.687+00	2025-02-14 09:44:51.667+00
optval_01JM1X4XSFWPWDB29T0EE8VKTM	White Marble	opt_01JM1X4XSCA6D1Z6YYFH1DJJBQ	\N	2025-02-14 09:37:59.570288+00	2025-02-14 09:44:51.687+00	2025-02-14 09:44:51.667+00
optval_01JM1X4XSFDQF1V4HVGA0QGBVJ	Rosso Levanto Marble	opt_01JM1X4XSCA6D1Z6YYFH1DJJBQ	\N	2025-02-14 09:37:59.570288+00	2025-02-14 09:44:51.687+00	2025-02-14 09:44:51.667+00
optval_01JM1X4XSFHS3P5Z9XZJSGAJS2	Kunis Breccia	opt_01JM1X4XSCA6D1Z6YYFH1DJJBQ	\N	2025-02-14 09:37:59.570288+00	2025-02-14 09:44:51.687+00	2025-02-14 09:44:51.667+00
optval_01JM1X4XSF3ENEZNSF7NMSXYE0	Rojo Alicante	opt_01JM1X4XSCA6D1Z6YYFH1DJJBQ	\N	2025-02-14 09:37:59.570288+00	2025-02-14 09:44:51.687+00	2025-02-14 09:44:51.667+00
optval_01JM1XHT050Y00MZCZFVGCJ0N8	Modellato Marble	opt_01JM1XHSZXCQM2RB02CT0KRVHS	\N	2025-02-14 09:45:01.682795+00	2025-02-14 09:54:55.006+00	2025-02-14 09:54:54.989+00
optval_01JM1XHT05E7MJTV8SEAEMA2TH	White Marble	opt_01JM1XHSZXCQM2RB02CT0KRVHS	\N	2025-02-14 09:45:01.682795+00	2025-02-14 09:54:55.006+00	2025-02-14 09:54:54.989+00
optval_01JM1XHT05GW6AQGMN6BFYCFPM	Rosso Levanto Marble	opt_01JM1XHSZXCQM2RB02CT0KRVHS	\N	2025-02-14 09:45:01.682795+00	2025-02-14 09:54:55.006+00	2025-02-14 09:54:54.989+00
optval_01JM1XHT05WSKD2XZSG2JPB991	Kunis Breccia	opt_01JM1XHSZXCQM2RB02CT0KRVHS	\N	2025-02-14 09:45:01.682795+00	2025-02-14 09:54:55.006+00	2025-02-14 09:54:54.989+00
optval_01JM1XHT05XQZ3D9FFQERMHTCD	Rojo Alicante	opt_01JM1XHSZXCQM2RB02CT0KRVHS	\N	2025-02-14 09:45:01.682795+00	2025-02-14 09:54:55.006+00	2025-02-14 09:54:54.989+00
optval_01JM1Y66XJ21RHB1TY4XQQ77G3	Modellato Marble	opt_01JM1Y66XECS56QVVET8TVR84A	\N	2025-02-14 09:56:10.275311+00	2025-02-14 10:02:01.754+00	2025-02-14 10:02:01.73+00
optval_01JM1Y66XJ6XCVWEHNHQSAJ7T5	White Marble	opt_01JM1Y66XECS56QVVET8TVR84A	\N	2025-02-14 09:56:10.275311+00	2025-02-14 10:02:01.754+00	2025-02-14 10:02:01.73+00
optval_01JM1Y66XJ182QP0Z687MS2N9H	Rosso Levanto Marble	opt_01JM1Y66XECS56QVVET8TVR84A	\N	2025-02-14 09:56:10.275311+00	2025-02-14 10:02:01.754+00	2025-02-14 10:02:01.73+00
optval_01JM1Y66XJ15N35FKQVCQXYRP2	Kunis Breccia	opt_01JM1Y66XECS56QVVET8TVR84A	\N	2025-02-14 09:56:10.275311+00	2025-02-14 10:02:01.754+00	2025-02-14 10:02:01.73+00
optval_01JM1Y66XJMJHAHRMV0PSEYPW5	Rojo Alicante	opt_01JM1Y66XECS56QVVET8TVR84A	\N	2025-02-14 09:56:10.275311+00	2025-02-14 10:02:01.754+00	2025-02-14 10:02:01.73+00
optval_01JM1YH974V10J31X3GA7BMG40	Modellato Marble	opt_01JM1YH9711BSMP9QYGNNRPNKN	\N	2025-02-14 10:02:13.079697+00	2025-02-14 10:03:56.987+00	2025-02-14 10:03:56.967+00
optval_01JM1YH974VR0BHEPG5RGY0S5F	White Marble	opt_01JM1YH9711BSMP9QYGNNRPNKN	\N	2025-02-14 10:02:13.079697+00	2025-02-14 10:03:56.987+00	2025-02-14 10:03:56.967+00
optval_01JM1YH974B741BZFTZVW04PH3	Rosso Levanto Marble	opt_01JM1YH9711BSMP9QYGNNRPNKN	\N	2025-02-14 10:02:13.079697+00	2025-02-14 10:03:56.987+00	2025-02-14 10:03:56.967+00
optval_01JM1YH974B2J80T3NMF29C1ED	Kunis Breccia	opt_01JM1YH9711BSMP9QYGNNRPNKN	\N	2025-02-14 10:02:13.079697+00	2025-02-14 10:03:56.987+00	2025-02-14 10:03:56.967+00
optval_01JM1YH9742BMGK5V47M7EY8DX	Rojo Alicante	opt_01JM1YH9711BSMP9QYGNNRPNKN	\N	2025-02-14 10:02:13.079697+00	2025-02-14 10:03:56.987+00	2025-02-14 10:03:56.967+00
optval_01JM1YPFTX51TTCCZS5Z9JZYN4	Modellato Marble	opt_01JM1YPFTTX2R9RSB42MWXZPYC	\N	2025-02-14 10:05:03.689478+00	2025-02-14 10:20:30.539+00	2025-02-14 10:20:30.512+00
optval_01JM1YPFTXNB3DFAB56GB7T0ER	White Marble	opt_01JM1YPFTTX2R9RSB42MWXZPYC	\N	2025-02-14 10:05:03.689478+00	2025-02-14 10:20:30.539+00	2025-02-14 10:20:30.512+00
optval_01JM1YPFTXA0VQ5V3MAMEQCN3Z	Rosso Levanto Marble	opt_01JM1YPFTTX2R9RSB42MWXZPYC	\N	2025-02-14 10:05:03.689478+00	2025-02-14 10:20:30.539+00	2025-02-14 10:20:30.512+00
optval_01JM1YPFTXA8VACFTVJ9BK0HPA	Kunis Breccia	opt_01JM1YPFTTX2R9RSB42MWXZPYC	\N	2025-02-14 10:05:03.689478+00	2025-02-14 10:20:30.539+00	2025-02-14 10:20:30.512+00
optval_01JM1YPFTXW5YQZXJCAQT635ZG	Rojo Alicante	opt_01JM1YPFTTX2R9RSB42MWXZPYC	\N	2025-02-14 10:05:03.689478+00	2025-02-14 10:20:30.539+00	2025-02-14 10:20:30.512+00
optval_01JM1ZKBVDHZYPTTSA4J7BM1JM	Modellato Marble	opt_01JM1ZKBVA75B5Q006AW44PY84	\N	2025-02-14 10:20:49.888992+00	2025-02-14 10:26:16.482+00	2025-02-14 10:26:16.462+00
optval_01JM1ZKBVDM49MW10WQBWG5ABH	White Marble	opt_01JM1ZKBVA75B5Q006AW44PY84	\N	2025-02-14 10:20:49.888992+00	2025-02-14 10:26:16.482+00	2025-02-14 10:26:16.462+00
optval_01JM1ZKBVETEM87YRCD7GYT2SB	Rosso Levanto Marble	opt_01JM1ZKBVA75B5Q006AW44PY84	\N	2025-02-14 10:20:49.888992+00	2025-02-14 10:26:16.482+00	2025-02-14 10:26:16.462+00
optval_01JM1ZKBVEZKTCYDQQCNKT0ZQS	Kunis Breccia	opt_01JM1ZKBVA75B5Q006AW44PY84	\N	2025-02-14 10:20:49.888992+00	2025-02-14 10:26:16.482+00	2025-02-14 10:26:16.462+00
optval_01JM1ZKBVECJGY0PX8100JDZNJ	Rojo Alicante	opt_01JM1ZKBVA75B5Q006AW44PY84	\N	2025-02-14 10:20:49.888992+00	2025-02-14 10:26:16.482+00	2025-02-14 10:26:16.462+00
optval_01JM1ZXS7B6XYRRW15CNTF7NYA	Modellato Marble	opt_01JM1ZXS78JCW70RSMMJHPBTA5	\N	2025-02-14 10:26:31.262457+00	2025-02-14 10:32:00.26+00	2025-02-14 10:32:00.227+00
optval_01JM1ZXS7BM9EM1PQT456CTR9M	White Marble	opt_01JM1ZXS78JCW70RSMMJHPBTA5	\N	2025-02-14 10:26:31.262457+00	2025-02-14 10:32:00.26+00	2025-02-14 10:32:00.227+00
optval_01JM1ZXS7BNFNXSY284MWKEPDJ	Rosso Levanto Marble	opt_01JM1ZXS78JCW70RSMMJHPBTA5	\N	2025-02-14 10:26:31.262457+00	2025-02-14 10:32:00.26+00	2025-02-14 10:32:00.227+00
optval_01JM1ZXS7BEA4946NH8EV6M9W1	Kunis Breccia	opt_01JM1ZXS78JCW70RSMMJHPBTA5	\N	2025-02-14 10:26:31.262457+00	2025-02-14 10:32:00.26+00	2025-02-14 10:32:00.227+00
optval_01JM1ZXS7BPE8K2ZKC0YKDZWR1	Rojo Alicante	opt_01JM1ZXS78JCW70RSMMJHPBTA5	\N	2025-02-14 10:26:31.262457+00	2025-02-14 10:32:00.261+00	2025-02-14 10:32:00.227+00
optval_01JM20CSYVF3GFX07QXQBJ3T06	Modellato Marble	opt_01JM20CSYRSD6Y20Z9T931KXS8	\N	2025-02-14 10:34:43.53264+00	2025-02-14 10:47:38.668+00	2025-02-14 10:47:38.639+00
optval_01JM20CSYVHHP8MHP6SH3HCGZ1	White Marble	opt_01JM20CSYRSD6Y20Z9T931KXS8	\N	2025-02-14 10:34:43.53264+00	2025-02-14 10:47:38.668+00	2025-02-14 10:47:38.639+00
optval_01JM20CSYV0X670DDVXK5ZEPNJ	Rosso Levanto Marble	opt_01JM20CSYRSD6Y20Z9T931KXS8	\N	2025-02-14 10:34:43.53264+00	2025-02-14 10:47:38.668+00	2025-02-14 10:47:38.639+00
optval_01JM20CSYV2HZJW2027SEZ9PB4	Kunis Breccia	opt_01JM20CSYRSD6Y20Z9T931KXS8	\N	2025-02-14 10:34:43.53264+00	2025-02-14 10:47:38.668+00	2025-02-14 10:47:38.639+00
optval_01JM20CSYVB7ZPV323ZSEXDSA9	Rojo Alicante	opt_01JM20CSYRSD6Y20Z9T931KXS8	\N	2025-02-14 10:34:43.53264+00	2025-02-14 10:47:38.668+00	2025-02-14 10:47:38.639+00
optval_01JM214XH894MAK6FYK06Q0BKQ	Modellato Marble	opt_01JM214XH5VN28J3G5JN056ZEB	\N	2025-02-14 10:47:53.626332+00	2025-02-14 10:48:29.912+00	2025-02-14 10:48:29.893+00
optval_01JM214XH82MR1N5D1N2WX9TNQ	White Marble	opt_01JM214XH5VN28J3G5JN056ZEB	\N	2025-02-14 10:47:53.626332+00	2025-02-14 10:48:29.912+00	2025-02-14 10:48:29.893+00
optval_01JM214XH8EG0MD5S6Q1QTHV67	Rosso Levanto Marble	opt_01JM214XH5VN28J3G5JN056ZEB	\N	2025-02-14 10:47:53.626332+00	2025-02-14 10:48:29.912+00	2025-02-14 10:48:29.893+00
optval_01JM214XH8RXNE3WJHSJRX2MJQ	Kunis Breccia	opt_01JM214XH5VN28J3G5JN056ZEB	\N	2025-02-14 10:47:53.626332+00	2025-02-14 10:48:29.912+00	2025-02-14 10:48:29.893+00
optval_01JM214XH8KJ2TGM1KJBB7W8NK	Rojo Alicante	opt_01JM214XH5VN28J3G5JN056ZEB	\N	2025-02-14 10:47:53.626332+00	2025-02-14 10:48:29.912+00	2025-02-14 10:48:29.893+00
optval_01JM2C9Y1R014CWWRB3S9AKB5D	Modellato Marble	opt_01JM2C9Y1KGFTXHFNFNWE8VPRT	\N	2025-02-14 14:02:52.332391+00	2025-02-14 14:15:56.231+00	2025-02-14 14:15:56.19+00
optval_01JM2C9Y1R6FQG7T2RPJ3D1CSZ	White Marble	opt_01JM2C9Y1KGFTXHFNFNWE8VPRT	\N	2025-02-14 14:02:52.332391+00	2025-02-14 14:15:56.231+00	2025-02-14 14:15:56.19+00
optval_01JM2C9Y1RJPGNA2CV0S3CS06Y	Rosso Levanto Marble	opt_01JM2C9Y1KGFTXHFNFNWE8VPRT	\N	2025-02-14 14:02:52.332391+00	2025-02-14 14:15:56.231+00	2025-02-14 14:15:56.19+00
optval_01JM2C9Y1SMMZK39VHTW19840X	Kunis Breccia	opt_01JM2C9Y1KGFTXHFNFNWE8VPRT	\N	2025-02-14 14:02:52.332391+00	2025-02-14 14:15:56.231+00	2025-02-14 14:15:56.19+00
optval_01JM2C9Y1SX8R99RFY13HV1M88	Rojo Alicante	opt_01JM2C9Y1KGFTXHFNFNWE8VPRT	\N	2025-02-14 14:02:52.332391+00	2025-02-14 14:15:56.231+00	2025-02-14 14:15:56.19+00
optval_01JM216BRX8AVRVM7WG2M1GDKE	Modellato Marble	opt_01JM216BRTFTMDNNYQYY4SX5EX	\N	2025-02-14 10:48:40.974869+00	2025-02-14 13:52:56.958+00	2025-02-14 13:52:56.935+00
optval_01JM216BRXRHR5E0QWRGANC2TK	White Marble	opt_01JM216BRTFTMDNNYQYY4SX5EX	\N	2025-02-14 10:48:40.974869+00	2025-02-14 13:52:56.958+00	2025-02-14 13:52:56.935+00
optval_01JM216BRXEG405V8VMRN9Y7CT	Rosso Levanto Marble	opt_01JM216BRTFTMDNNYQYY4SX5EX	\N	2025-02-14 10:48:40.974869+00	2025-02-14 13:52:56.958+00	2025-02-14 13:52:56.935+00
optval_01JM216BRXQPTSV61QEJS4BV78	Kunis Breccia	opt_01JM216BRTFTMDNNYQYY4SX5EX	\N	2025-02-14 10:48:40.974869+00	2025-02-14 13:52:56.958+00	2025-02-14 13:52:56.935+00
optval_01JM216BRX1ATNH63CQ65Y29JW	Rojo Alicante	opt_01JM216BRTFTMDNNYQYY4SX5EX	\N	2025-02-14 10:48:40.974869+00	2025-02-14 13:52:56.958+00	2025-02-14 13:52:56.935+00
optval_01JM2D2W0M0GDPVP2SC3G47RPJ	Modellato Marble	opt_01JM2D2W0HGWBSC6ZD346BJNGZ	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00
optval_01JM2D2W0MX3D8YCHCFJ0MSJ6D	White Marble	opt_01JM2D2W0HGWBSC6ZD346BJNGZ	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00
optval_01JM2D2W0MMW6J0R1S1WXJNQZR	Rosso Levanto Marble	opt_01JM2D2W0HGWBSC6ZD346BJNGZ	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00
optval_01JM2D2W0MPE372BXJW964PD6H	Kunis Breccia	opt_01JM2D2W0HGWBSC6ZD346BJNGZ	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00
optval_01JM2D2W0MCNJX2M705EFSSXJC	Rojo Alicante	opt_01JM2D2W0HGWBSC6ZD346BJNGZ	\N	2025-02-14 14:16:29.447067+00	2025-02-14 14:25:36.823+00	2025-02-14 14:25:36.789+00
optval_01JM2BQZE8K95SGNE57W137Y22	Modellato Marble	opt_01JM2BQZE65972NFKNPRY4Y4KJ	\N	2025-02-14 13:53:03.929393+00	2025-02-14 13:54:50.848+00	2025-02-14 13:54:50.821+00
optval_01JM2BQZE82KZ4YECTD650ZK6S	White Marble	opt_01JM2BQZE65972NFKNPRY4Y4KJ	\N	2025-02-14 13:53:03.929393+00	2025-02-14 13:54:50.848+00	2025-02-14 13:54:50.821+00
optval_01JM2BQZE8K1JTTAQFXYK02GBX	Rosso Levanto Marble	opt_01JM2BQZE65972NFKNPRY4Y4KJ	\N	2025-02-14 13:53:03.929393+00	2025-02-14 13:54:50.848+00	2025-02-14 13:54:50.821+00
optval_01JM2BQZE8K52NWARCQNJGJG6B	Kunis Breccia	opt_01JM2BQZE65972NFKNPRY4Y4KJ	\N	2025-02-14 13:53:03.929393+00	2025-02-14 13:54:50.848+00	2025-02-14 13:54:50.821+00
optval_01JM2BQZE8RPBHSFM28YNYQ7EJ	Rojo Alicante	opt_01JM2BQZE65972NFKNPRY4Y4KJ	\N	2025-02-14 13:53:03.929393+00	2025-02-14 13:54:50.848+00	2025-02-14 13:54:50.821+00
optval_01JM2DKW75VG67505GT1HVZ8QV	Modellato Marble	opt_01JM2DKW6Z0WVQV17NQ6WVPTHY	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00
optval_01JM2DKW75HH933T2DXNYHXPCZ	White Marble	opt_01JM2DKW6Z0WVQV17NQ6WVPTHY	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00
optval_01JM2DKW75MBSJZNR82KEMRXVZ	Rosso Levanto Marble	opt_01JM2DKW6Z0WVQV17NQ6WVPTHY	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00
optval_01JM2DKW75ANFNV640CRBM5E8P	Kunis Breccia	opt_01JM2DKW6Z0WVQV17NQ6WVPTHY	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00
optval_01JM2DKW75XP4A83NAZQQGRM29	Rojo Alicante	opt_01JM2DKW6Z0WVQV17NQ6WVPTHY	\N	2025-02-14 14:25:46.707526+00	2025-02-14 14:30:35.873+00	2025-02-14 14:30:35.84+00
optval_01JM2DWYHGZEGMAY69VXXPVBZM	Modellato Marble	opt_01JM2DWYHC9BP1T1YYZWPKA7GS	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00
optval_01JM2DWYHG9TS83Y7BSZKBJQA7	White Marble	opt_01JM2DWYHC9BP1T1YYZWPKA7GS	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00
optval_01JM2DWYHGWNMPCZRMGN2H02C7	Rosso Levanto Marble	opt_01JM2DWYHC9BP1T1YYZWPKA7GS	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00
optval_01JM2DWYHGNHZXMT2XHZGQZ1DC	Kunis Breccia	opt_01JM2DWYHC9BP1T1YYZWPKA7GS	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00
optval_01JM2DWYHGHPRA3XST99KXWD0X	Rojo Alicante	opt_01JM2DWYHC9BP1T1YYZWPKA7GS	\N	2025-02-14 14:30:44.004885+00	2025-02-14 14:33:33.735+00	2025-02-14 14:33:33.708+00
optval_01JM2E2ATKD6TY1JEBM05J4Q6T	Modellato Marble	opt_01JM2E2ATE61NCW3YD1V5G69MZ	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.791+00	2025-02-14 14:43:26.757+00
optval_01JM2E2ATK06KRFCRTEDC7YGZB	White Marble	opt_01JM2E2ATE61NCW3YD1V5G69MZ	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.791+00	2025-02-14 14:43:26.757+00
optval_01JM2E2ATMFRGY06SGFHB9MZ2T	Rosso Levanto Marble	opt_01JM2E2ATE61NCW3YD1V5G69MZ	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.791+00	2025-02-14 14:43:26.757+00
optval_01JM2E2ATM34CFGDSSAFN65EJW	Kunis Breccia	opt_01JM2E2ATE61NCW3YD1V5G69MZ	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.791+00	2025-02-14 14:43:26.757+00
optval_01JM2E2ATMWWQ67X6FE8RCTWRQ	Rojo Alicante	opt_01JM2E2ATE61NCW3YD1V5G69MZ	\N	2025-02-14 14:33:40.409678+00	2025-02-14 14:43:26.791+00	2025-02-14 14:43:26.757+00
optval_01JM2EME6J3106G8K5TNGT8KWF	Modellato Marble	opt_01JM2EME6GMKQ51ENPY60GBBM5	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.627+00	2025-02-14 15:36:51.594+00
optval_01JM2EME6JJQE2NKZP8QJTCC18	White Marble	opt_01JM2EME6GMKQ51ENPY60GBBM5	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.627+00	2025-02-14 15:36:51.594+00
optval_01JM2EME6JXN1AFN00CAZGJYWJ	Rosso Levanto Marble	opt_01JM2EME6GMKQ51ENPY60GBBM5	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.627+00	2025-02-14 15:36:51.594+00
optval_01JM2EME6KB8ZEJSM4XKBMJJVG	Kunis Breccia	opt_01JM2EME6GMKQ51ENPY60GBBM5	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00
optval_01JM2EME6KKE2XKQ74YRVV0E3A	Rojo Alicante	opt_01JM2EME6GMKQ51ENPY60GBBM5	\N	2025-02-14 14:43:33.705891+00	2025-02-14 15:36:51.628+00	2025-02-14 15:36:51.594+00
optval_01JM2HQQ55XTZFE9KFWC0RFXX0	Modellato Marble	opt_01JM2HQQ52FFPQEZ33HR81AK30	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00
optval_01JM2HQQ55V30HFK3WA2V9N3N9	White Marble	opt_01JM2HQQ52FFPQEZ33HR81AK30	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00
optval_01JM2HQQ55K6PZKMDGF3SPJTTB	Rosso Levanto Marble	opt_01JM2HQQ52FFPQEZ33HR81AK30	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00
optval_01JM2HQQ5569H1JW2JDHR3G2X5	Kunis Breccia	opt_01JM2HQQ52FFPQEZ33HR81AK30	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00
optval_01JM2HQQ55XW4ZVJ4C3V191J0Q	Rojo Alicante	opt_01JM2HQQ52FFPQEZ33HR81AK30	\N	2025-02-14 15:37:46.892649+00	2025-02-14 15:39:13.487+00	2025-02-14 15:39:13.463+00
optval_01JM2HTJ5BQSZWA5RMNV37EB6M	Modellato Marble	opt_01JM2HTJ59QSHHY19REGTTT9S1	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.558+00	2025-02-14 15:42:36.535+00
optval_01JM2HTJ5BHN3C36PE8P64AVZG	White Marble	opt_01JM2HTJ59QSHHY19REGTTT9S1	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.558+00	2025-02-14 15:42:36.535+00
optval_01JM2HTJ5CSM1SJKQ07ZC9N6TC	Rosso Levanto Marble	opt_01JM2HTJ59QSHHY19REGTTT9S1	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.558+00	2025-02-14 15:42:36.535+00
optval_01JM2HTJ5CB4HFN2KZKBYCCGZD	Kunis Breccia	opt_01JM2HTJ59QSHHY19REGTTT9S1	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00
optval_01JM2HTJ5C677EWYM9DJEDYYQZ	Rojo Alicante	opt_01JM2HTJ59QSHHY19REGTTT9S1	\N	2025-02-14 15:39:20.094585+00	2025-02-14 15:42:36.559+00	2025-02-14 15:42:36.535+00
optval_01JM2J0QDAEK8XZFRVS3AK4ZAT	Modellato Marble	opt_01JM2J0QD6E1S9Y83M3EFF5PDK	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00
optval_01JM2J0QDAKG8Q19D4HENK84DE	White Marble	opt_01JM2J0QD6E1S9Y83M3EFF5PDK	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00
optval_01JM2J0QDAAPMCHSVWGYHF6F92	Rosso Levanto Marble	opt_01JM2J0QD6E1S9Y83M3EFF5PDK	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00
optval_01JM2J0QDANBXGC9839AV713ZG	Kunis Breccia	opt_01JM2J0QD6E1S9Y83M3EFF5PDK	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00
optval_01JM2J0QDAHJ80WD3N0S0441W1	Rojo Alicante	opt_01JM2J0QD6E1S9Y83M3EFF5PDK	\N	2025-02-14 15:42:42.066506+00	2025-02-14 15:49:16.238+00	2025-02-14 15:49:16.213+00
optval_01JM2JCZYVV3PZDRE1E4NAJCBX	Modellato Marble	opt_01JM2JCZYRWJFBKD943A9VMDFH	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00
optval_01JM2JCZYVVH3YCNBWHN306GJ2	White Marble	opt_01JM2JCZYRWJFBKD943A9VMDFH	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00
optval_01JM2JCZYVN1CXR91Y0PN92YZ6	Rosso Levanto Marble	opt_01JM2JCZYRWJFBKD943A9VMDFH	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00
optval_01JM2JCZYVV9XKZGJ1C9HJGBNQ	Kunis Breccia	opt_01JM2JCZYRWJFBKD943A9VMDFH	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00
optval_01JM2JCZYVEM15F452Q4MJF5ZR	Rojo Alicante	opt_01JM2JCZYRWJFBKD943A9VMDFH	\N	2025-02-14 15:49:24.042022+00	2025-02-14 15:52:47.605+00	2025-02-14 15:52:47.583+00
optval_01JM2JKYPMWMHW28WK1GV9ZB7V	Modellato Marble	opt_01JM2JKYPJHP2CXP1QNAX2GT64	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00
optval_01JM2JKYPMH9D7X1DR1BCM1DMF	White Marble	opt_01JM2JKYPJHP2CXP1QNAX2GT64	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00
optval_01JM2JKYPM96KXJP8GP8KQ3F6S	Rosso Levanto Marble	opt_01JM2JKYPJHP2CXP1QNAX2GT64	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00
optval_01JM2JKYPMP1EZKH7QMJ44SNHZ	Kunis Breccia	opt_01JM2JKYPJHP2CXP1QNAX2GT64	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00
optval_01JM2JKYPMHAPCCXQ29AWGC1K9	Rojo Alicante	opt_01JM2JKYPJHP2CXP1QNAX2GT64	\N	2025-02-14 15:53:12.130475+00	2025-02-14 16:01:40.529+00	2025-02-14 16:01:40.509+00
\.


--
-- Data for Name: product_sales_channel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_sales_channel (product_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01JM18DSK7TAY1V51GANPG18AV	sc_01JM18DQRAB13QQK6V7535YDR1	prodsc_01JM18DSMQCCXSZFSJ41X04866	2025-02-14 03:35:50.166436+00	2025-02-14 03:35:50.166436+00	\N
prod_01JM18DSK7W9Z90KJWFD1KCV2B	sc_01JM18DQRAB13QQK6V7535YDR1	prodsc_01JM18DSMQ6J5KZ3XA3XN3GRWF	2025-02-14 03:35:50.166436+00	2025-02-14 03:35:50.166436+00	\N
prod_01JM18DSK7815R7Y7SR83MPR32	sc_01JM18DQRAB13QQK6V7535YDR1	prodsc_01JM18DSMQSVGWVKC7FKQM7WYH	2025-02-14 03:35:50.166436+00	2025-02-14 03:35:50.166436+00	\N
prod_01JM18DSK77PEYBDSR2C19BESV	sc_01JM18DQRAB13QQK6V7535YDR1	prodsc_01JM18DSMQCMHK7AVBB7133NBD	2025-02-14 03:35:50.166436+00	2025-02-14 03:35:50.166436+00	\N
\.


--
-- Data for Name: product_shipping_profile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_shipping_profile (product_id, shipping_profile_id, id, created_at, updated_at, deleted_at) FROM stdin;
prod_01JM18DSK7TAY1V51GANPG18AV	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM18DSMX9T415QKAVQ2DBWKQ	2025-02-14 03:35:50.172065+00	2025-02-14 03:35:50.172065+00	\N
prod_01JM18DSK7W9Z90KJWFD1KCV2B	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM18DSMX1DRH4JTFX16ZA7PN	2025-02-14 03:35:50.172065+00	2025-02-14 03:35:50.172065+00	\N
prod_01JM18DSK7815R7Y7SR83MPR32	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM18DSMX4ZEBZHK37TX2QEM2	2025-02-14 03:35:50.172065+00	2025-02-14 03:35:50.172065+00	\N
prod_01JM18DSK77PEYBDSR2C19BESV	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM18DSMXREB12QS9377Z3HQ6	2025-02-14 03:35:50.172065+00	2025-02-14 03:35:50.172065+00	\N
prod_01JM1E0BZANZP61ADKJDGFNDDT	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM1E0C06MSACS5TWW1JSJD0H	2025-02-14 05:13:21.664427+00	2025-02-14 05:14:37.675+00	2025-02-14 05:14:37.674+00
prod_01JM1X4XS4ZK22S1J0RVAFVZ3D	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM1X4XT8REK2YWHY9YT83AZ4	2025-02-14 09:37:59.623459+00	2025-02-14 09:44:51.67+00	2025-02-14 09:44:51.67+00
prod_01JM1XHSZPPZHYP21KAKY7GDXC	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM1XHT0KHYJ4JFF3C2JFSFWK	2025-02-14 09:45:01.714289+00	2025-02-14 09:54:54.992+00	2025-02-14 09:54:54.992+00
prod_01JM1Y66XAHV0VX61YE1W723E0	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM1Y66Y15V5PWKFA2B0VPQHF	2025-02-14 09:56:10.304465+00	2025-02-14 10:02:01.733+00	2025-02-14 10:02:01.733+00
prod_01JM1YH96W1FT2HV43FS4A1XZ7	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM1YH97HA2Q8GDZWZJJFZWKF	2025-02-14 10:02:13.10431+00	2025-02-14 10:03:56.968+00	2025-02-14 10:03:56.968+00
prod_01JM1YPFTQQAHWNCNFP1G8FGZS	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM1YPFVA3XAZN5H6X3C1NCCY	2025-02-14 10:05:03.72156+00	2025-02-14 10:20:30.516+00	2025-02-14 10:20:30.516+00
prod_01JM1ZKBV6FEBE1G34E5M7TDG6	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM1ZKBW1WKV4CQANP6E9QR2E	2025-02-14 10:20:49.916283+00	2025-02-14 10:26:16.465+00	2025-02-14 10:26:16.465+00
prod_01JM1ZXS73KBZRW0E30H8EM266	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM1ZXS7XXTHHJA2JJXEC0F1E	2025-02-14 10:26:31.289984+00	2025-02-14 10:32:00.233+00	2025-02-14 10:32:00.232+00
prod_01JM20CSYM758J4KV71BBPEXFZ	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM20CSZEWEXDB0TR5ECZFPDR	2025-02-14 10:34:43.561366+00	2025-02-14 10:47:38.641+00	2025-02-14 10:47:38.64+00
prod_01JM214XH09Q6V6J76RJN70SWF	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM214XHPENA7GKB3KKFX5M5P	2025-02-14 10:47:53.652591+00	2025-02-14 10:48:29.895+00	2025-02-14 10:48:29.895+00
prod_01JM216BRNW43T5W3PVRFQ3JQM	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM216BSFQE7119QA20BKQTM4	2025-02-14 10:48:41.000141+00	2025-02-14 13:52:56.94+00	2025-02-14 13:52:56.94+00
prod_01JM2BQZDYMD186EYYK52YZXXR	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2BQZESNAGHYF7JSVBABQCQ	2025-02-14 13:53:03.960568+00	2025-02-14 13:54:50.827+00	2025-02-14 13:54:50.827+00
prod_01JM2BVHSQ2M646J7WF858507T	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2BVHTFC9VQ0KQXGEVDQTG0	2025-02-14 13:55:01.070577+00	2025-02-14 13:55:01.127+00	2025-02-14 13:55:01.127+00
prod_01JM2C5B08QXSSX1EJGFYC8XQW	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2C5B1ARXJKCH77MGM37104	2025-02-14 14:00:21.802174+00	2025-02-14 14:00:21.876+00	2025-02-14 14:00:21.875+00
prod_01JM2C82RM66VK9MQG6G0HMQHN	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2C82SCKNP68F4VZWK0S9Q1	2025-02-14 14:01:51.659509+00	2025-02-14 14:01:51.75+00	2025-02-14 14:01:51.749+00
prod_01JM2C8V2C7KWSKFNCZRPY4T86	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2C8V3F596TJMHCH68SXK3B	2025-02-14 14:02:16.559224+00	2025-02-14 14:02:16.608+00	2025-02-14 14:02:16.607+00
prod_01JM2C9Y1GFHME9JGCVMDW5QQJ	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2C9Y26HBGKT6PVRP0SGWHB	2025-02-14 14:02:52.358362+00	2025-02-14 14:15:56.192+00	2025-02-14 14:15:56.192+00
prod_01JM2D2W0CNQT5B7Y7ATY88HE7	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2D2W29QJ8YKWCR7HT9W8XB	2025-02-14 14:16:29.513003+00	2025-02-14 14:25:36.792+00	2025-02-14 14:25:36.791+00
prod_01JM2DKW6R5QPTQWZTFEPAZY5V	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2DKW8RWWXE7RHA4N3F9BTR	2025-02-14 14:25:46.775987+00	2025-02-14 14:30:35.838+00	2025-02-14 14:30:35.838+00
prod_01JM2DWYH6WWGWX4SJYBCDP3ND	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2DWYK1QKRQX8368CQ2F4TC	2025-02-14 14:30:44.070246+00	2025-02-14 14:33:33.71+00	2025-02-14 14:33:33.71+00
prod_01JM2E2AT36CVJX97E35K089W8	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2E2AW55JXMCYN3E6EBGXK0	2025-02-14 14:33:40.484589+00	2025-02-14 14:43:26.761+00	2025-02-14 14:43:26.761+00
prod_01JM2EME6DXF5EBNHSCGDK6AR8	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2EME7VG3MF2NWA75Z70PP5	2025-02-14 14:43:33.755025+00	2025-02-14 15:36:51.596+00	2025-02-14 15:36:51.596+00
prod_01JM2HQQ4VSP0SAZB0BSS7MSMC	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2HQQ6QPRWF67NWA4ERYRN5	2025-02-14 15:37:46.966126+00	2025-02-14 15:39:13.468+00	2025-02-14 15:39:13.468+00
prod_01JM2HTJ546FNVY2DCHXWX5R7V	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2HTJ6G72HBX0Q53X8K3NKD	2025-02-14 15:39:20.143213+00	2025-02-14 15:42:36.536+00	2025-02-14 15:42:36.536+00
prod_01JM2J0QCVT5C2W5CE36Y8YVN3	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2J0QE2AEQS3NMGJZEZHGSY	2025-02-14 15:42:42.113668+00	2025-02-14 15:49:16.215+00	2025-02-14 15:49:16.215+00
prod_01JM2JCZYKS64JW7AHA5KDNWHY	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2JCZZP45NTBQA9QPN00YNE	2025-02-14 15:49:24.085036+00	2025-02-14 15:52:47.587+00	2025-02-14 15:52:47.587+00
prod_01JM2JKDWT29Y612M5Z4ZPTDVK	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2JKDXQB6XQKX7SBRWMAHH8	2025-02-14 15:52:54.9667+00	2025-02-14 15:52:55.01+00	2025-02-14 15:52:55.009+00
prod_01JM2JKYPA276V6W1PMEFFTQCK	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2JKYQAFB01M2XZJQWH51SV	2025-02-14 15:53:12.169889+00	2025-02-14 16:01:40.51+00	2025-02-14 16:01:40.51+00
prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH	sp_01JM18DSFFZW6A3X2BVSRWHYAK	prodsp_01JM2K3ZS0TBJDGAK1CD1XBAEK	2025-02-14 16:01:57.535928+00	2025-02-14 16:01:57.535928+00	\N
\.


--
-- Data for Name: product_tag; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_tag (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_tags; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_tags (product_id, product_tag_id) FROM stdin;
\.


--
-- Data for Name: product_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_type (id, value, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: product_variant; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variant (id, title, sku, barcode, ean, upc, allow_backorder, manage_inventory, hs_code, origin_country, mid_code, material, weight, length, height, width, metadata, variant_rank, product_id, created_at, updated_at, deleted_at) FROM stdin;
variant_01JM18DSNACS3GXYYB39GFMKPX	S / Black	SHIRT-S-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV	2025-02-14 03:35:50.188+00	2025-02-14 03:35:50.188+00	\N
variant_01JM18DSNBYTFQ1NCE20H3ZSQ8	S / White	SHIRT-S-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV	2025-02-14 03:35:50.188+00	2025-02-14 03:35:50.188+00	\N
variant_01JM18DSNBZ7305PJ1BB16B7NJ	M / Black	SHIRT-M-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV	2025-02-14 03:35:50.188+00	2025-02-14 03:35:50.188+00	\N
variant_01JM18DSNBKGQBK8MTNPBP4WGK	M / White	SHIRT-M-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV	2025-02-14 03:35:50.188+00	2025-02-14 03:35:50.188+00	\N
variant_01JM18DSNBBW851G7XADR5Y11G	L / Black	SHIRT-L-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV	2025-02-14 03:35:50.188+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNBJ6MZ96S8DFKTCTJZ	L / White	SHIRT-L-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNB55W3XDMBK0Y8QWD6	XL / Black	SHIRT-XL-BLACK	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNBRM5FFHXBTZ8DYG8D	XL / White	SHIRT-XL-WHITE	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7TAY1V51GANPG18AV	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNB6TMM157AD54G8JNK	M	SWEATSHIRT-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7W9Z90KJWFD1KCV2B	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNBQEC5YPHMEF90YH6V	L	SWEATSHIRT-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7W9Z90KJWFD1KCV2B	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNC9CH6Y05WGBSF2P7A	XL	SWEATSHIRT-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7W9Z90KJWFD1KCV2B	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNCWH0FSR51J3GMP2J5	S	SWEATPANTS-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7815R7Y7SR83MPR32	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNC9YD7MY1RS24BRRAN	M	SWEATPANTS-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7815R7Y7SR83MPR32	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNCJWHT8XE7NW8GR0P3	L	SWEATPANTS-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7815R7Y7SR83MPR32	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNC978BYBNCGC6MNCCJ	XL	SWEATPANTS-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK7815R7Y7SR83MPR32	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNCMPAPM2E7A096B2JY	S	SHORTS-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK77PEYBDSR2C19BESV	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNCW8Q9A9TFMFYNBX2C	M	SHORTS-M	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK77PEYBDSR2C19BESV	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNC0VTDG213TNW0YMKJ	L	SHORTS-L	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK77PEYBDSR2C19BESV	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNCDA0YH5QGTSY5KKTY	XL	SHORTS-XL	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM18DSK77PEYBDSR2C19BESV	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM18DSNBCP10KK5FM55NC1P6	S	SWEATSHIRT-S	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"dsa": "sdsd"}	0	prod_01JM18DSK7W9Z90KJWFD1KCV2B	2025-02-14 03:35:50.189+00	2025-02-14 03:35:50.189+00	\N
variant_01JM1E0C0N5YP45XWKT9FEZMZ8	Plinth \n      Plinth Plinth - Black S	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM1E0BZANZP61ADKJDGFNDDT	2025-02-14 05:13:21.686+00	2025-02-14 05:14:37.66+00	2025-02-14 05:14:37.65+00
variant_01JM1E0C0N5VRYBWD3WP9X5QHA	Plinth \n      Plinth Plinth - Black M	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM1E0BZANZP61ADKJDGFNDDT	2025-02-14 05:13:21.686+00	2025-02-14 05:14:37.66+00	2025-02-14 05:14:37.65+00
variant_01JM1E0C0NY8EENH3GJ708M5WP	Plinth \n      Plinth Plinth - Black L	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM1E0BZANZP61ADKJDGFNDDT	2025-02-14 05:13:21.686+00	2025-02-14 05:14:37.66+00	2025-02-14 05:14:37.65+00
variant_01JM1E0C0N8K92B4ZSE30JT615	Plinth \n      Plinth Plinth - Black XL	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM1E0BZANZP61ADKJDGFNDDT	2025-02-14 05:13:21.686+00	2025-02-14 05:14:37.66+00	2025-02-14 05:14:37.65+00
variant_01JM1E0C0N5G5927E2G2VBRX63	Plinth \n      Plinth Plinth - White S	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM1E0BZANZP61ADKJDGFNDDT	2025-02-14 05:13:21.686+00	2025-02-14 05:14:37.66+00	2025-02-14 05:14:37.65+00
variant_01JM1E0C0NF88ZPW5JD3SCZ186	Plinth \n      Plinth Plinth - White M	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM1E0BZANZP61ADKJDGFNDDT	2025-02-14 05:13:21.686+00	2025-02-14 05:14:37.66+00	2025-02-14 05:14:37.65+00
variant_01JM1E0C0P7G25GVZ4X3QT2GCJ	Plinth \n      Plinth Plinth - White L	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM1E0BZANZP61ADKJDGFNDDT	2025-02-14 05:13:21.686+00	2025-02-14 05:14:37.66+00	2025-02-14 05:14:37.65+00
variant_01JM1E0C0PGGR2N4YVX50M38BJ	Plinth \n      Plinth Plinth - White XL	\N	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	\N	0	prod_01JM1E0BZANZP61ADKJDGFNDDT	2025-02-14 05:13:21.686+00	2025-02-14 05:14:37.661+00	2025-02-14 05:14:37.65+00
variant_01JM1X4XTQQBG6VK83CSAY1GRR	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1X4XS4ZK22S1J0RVAFVZ3D	2025-02-14 09:37:59.639+00	2025-02-14 09:44:51.679+00	2025-02-14 09:44:51.667+00
variant_01JM1X4XTQ34CBRGMYFCNA4GMR	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1X4XS4ZK22S1J0RVAFVZ3D	2025-02-14 09:37:59.64+00	2025-02-14 09:44:51.679+00	2025-02-14 09:44:51.667+00
variant_01JM1X4XTQY4YRH3N0CSS33T64	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1X4XS4ZK22S1J0RVAFVZ3D	2025-02-14 09:37:59.64+00	2025-02-14 09:44:51.679+00	2025-02-14 09:44:51.667+00
variant_01JM1X4XTQFVB7NPPG2JFA8VFW	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1X4XS4ZK22S1J0RVAFVZ3D	2025-02-14 09:37:59.64+00	2025-02-14 09:44:51.679+00	2025-02-14 09:44:51.667+00
variant_01JM1X4XTQGZKC0FSR2PX8ZSXB	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1X4XS4ZK22S1J0RVAFVZ3D	2025-02-14 09:37:59.64+00	2025-02-14 09:44:51.679+00	2025-02-14 09:44:51.667+00
variant_01JM1XHT11068FC4SMKD3HRH44	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1XHSZPPZHYP21KAKY7GDXC	2025-02-14 09:45:01.729+00	2025-02-14 09:54:54.998+00	2025-02-14 09:54:54.989+00
variant_01JM2D2W2RZT6C47TTA5QWMC0B	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-1_640x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_640x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_640x.jpg", "https://interioricons.com/cdn/shop/files/1740-1_60x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_60x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_60x.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2D2W0CNQT5B7Y7ATY88HE7	2025-02-14 14:16:29.528+00	2025-02-14 14:25:36.805+00	2025-02-14 14:25:36.789+00
variant_01JM1XHT11A05YH281BGDA282F	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1XHSZPPZHYP21KAKY7GDXC	2025-02-14 09:45:01.729+00	2025-02-14 09:54:54.998+00	2025-02-14 09:54:54.989+00
variant_01JM1XHT11SXAW5R5AB2HSX3S4	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1XHSZPPZHYP21KAKY7GDXC	2025-02-14 09:45:01.729+00	2025-02-14 09:54:54.998+00	2025-02-14 09:54:54.989+00
variant_01JM1XHT11HRYSSBDHN2TQCMT9	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1XHSZPPZHYP21KAKY7GDXC	2025-02-14 09:45:01.729+00	2025-02-14 09:54:54.998+00	2025-02-14 09:54:54.989+00
variant_01JM1XHT11GVVZMEQDH211SDCJ	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1XHSZPPZHYP21KAKY7GDXC	2025-02-14 09:45:01.729+00	2025-02-14 09:54:54.998+00	2025-02-14 09:54:54.989+00
variant_01JM1Y66YKMMR0P5BTRW029705	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg?v=1713357821", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg?v=1728570082", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg?v=1702482823", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg?v=1713455034", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg?v=1688722552", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg?v=1702377001", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg?v=1709736705", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg?v=1713255258", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg?v=1704804323", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg?v=1730804242", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg?v=1697460750", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg?v=1726588136", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg?v=1704452480", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg?v=1704466854", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg?v=1712839949", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg?v=1734000800", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg?v=1706004602"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1Y66XAHV0VX61YE1W723E0	2025-02-14 09:56:10.324+00	2025-02-14 10:02:01.743+00	2025-02-14 10:02:01.73+00
variant_01JM1ZKBWGN28JANK0VCCV25W8	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZKBV6FEBE1G34E5M7TDG6	2025-02-14 10:20:49.937+00	2025-02-14 10:26:16.473+00	2025-02-14 10:26:16.462+00
variant_01JM1Y66YKVKKQVCS964M4V6WT	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg?v=1692109644", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg?v=1692109644", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg?v=1720696215", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg?v=1694432597", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg?v=1734001124&width=1520", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg?v=1692109644", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg?v=1734001124&width=760\\n", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg?v=1734001124&width=760\\n", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg?v=1713357821", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg?v=1728570082", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg?v=1702482823", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg?v=1713455034", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg?v=1688722552", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg?v=1702377001", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg?v=1709736705", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg?v=1713255258", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg?v=1704804323", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg?v=1730804242", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg?v=1697460750", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg?v=1726588136", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg?v=1704452480", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg?v=1704466854", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg?v=1712839949", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg?v=1734000800", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg?v=1706004602", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg?v=1729004924"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1Y66XAHV0VX61YE1W723E0	2025-02-14 09:56:10.323+00	2025-02-14 10:02:01.743+00	2025-02-14 10:02:01.73+00
variant_01JM1Y66YKGHRE5TPHAYKBHH1A	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg?v=1712839910", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg?v=1712839910", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg?v=1738857738", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg?v=1719932285", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg?v=1738857738", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg?v=1738857680&width=1520", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg?v=1712839910", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg?v=1738857738", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg?v=1738857680&width=760\\n", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg?v=1738857680&width=760\\n", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg?v=1713357821", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg?v=1728570082", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg?v=1702482823", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg?v=1713455034", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg?v=1688722552", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg?v=1702377001", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg?v=1709736705", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg?v=1713255258", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg?v=1704804323", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg?v=1730804242", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg?v=1697460750", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg?v=1726588136", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg?v=1704452480", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg?v=1704466854", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg?v=1712839949", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg?v=1734000800", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg?v=1706004602"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1Y66XAHV0VX61YE1W723E0	2025-02-14 09:56:10.324+00	2025-02-14 10:02:01.743+00	2025-02-14 10:02:01.73+00
variant_01JM1Y66YK45WE0CFB0MQW8VPN	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg?v=1721904361", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg?v=1721904361", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg?v=1722006767", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg?v=1721985320", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg?v=1718797102", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg?v=1716395618", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg?v=1722006767", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg?v=1721904361", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg?v=1722006767", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\\n", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\\n", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg?v=1713357821", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg?v=1728570082", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg?v=1702482823", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg?v=1713455034", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg?v=1688722552", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg?v=1702377001", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg?v=1709736705", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg?v=1713255258", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg?v=1704804323", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg?v=1730804242", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg?v=1697460750", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg?v=1726588136", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg?v=1704452480", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg?v=1704466854", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg?v=1712839949", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg?v=1734000800", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg?v=1706004602"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1Y66XAHV0VX61YE1W723E0	2025-02-14 09:56:10.324+00	2025-02-14 10:02:01.743+00	2025-02-14 10:02:01.73+00
variant_01JM1Y66YKZPNQYKYYGW9TYJJ2	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg?v=1725975902&width=600", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png?v=1725977660&width=600", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg?v=1721904375", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg?v=1721904375", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg?v=1721904384&width=1520", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg?v=1721904375", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg?v=1721904376&width=760\\n", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg?v=1721904376&width=760\\n", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg?v=1713357821", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg?v=1728570082", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg?v=1702482823", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg?v=1713455034", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg?v=1734001124", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg?v=1688722552", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg?v=1702377001", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg?v=1709736705", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg?v=1713255258", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg?v=1704804323", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg?v=1730804242", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg?v=1697460750", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg?v=1726588136", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg?v=1704452480", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg?v=1704466854", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg?v=1712839949", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg?v=1734000800", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg?v=1706004602"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1Y66XAHV0VX61YE1W723E0	2025-02-14 09:56:10.324+00	2025-02-14 10:02:01.743+00	2025-02-14 10:02:01.73+00
variant_01JM1YH98414QZVY82GVX028DQ	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YH96W1FT2HV43FS4A1XZ7	2025-02-14 10:02:13.125+00	2025-02-14 10:03:56.977+00	2025-02-14 10:03:56.967+00
variant_01JM20CSZZ7AP35T4ZZJ2K7SRP	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM20CSYM758J4KV71BBPEXFZ	2025-02-14 10:34:43.584+00	2025-02-14 10:47:38.656+00	2025-02-14 10:47:38.639+00
variant_01JM2BQZF62K4BM0W964MM00KN	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2BQZDYMD186EYYK52YZXXR	2025-02-14 13:53:03.974+00	2025-02-14 13:54:50.836+00	2025-02-14 13:54:50.821+00
variant_01JM1YH984A0FAA3XHASS25RZD	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YH96W1FT2HV43FS4A1XZ7	2025-02-14 10:02:13.125+00	2025-02-14 10:03:56.977+00	2025-02-14 10:03:56.967+00
variant_01JM1YH985DCQ83G2NHNCQ8AC6	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YH96W1FT2HV43FS4A1XZ7	2025-02-14 10:02:13.125+00	2025-02-14 10:03:56.977+00	2025-02-14 10:03:56.967+00
variant_01JM1YH9853PRBDB84TBSCAZS6	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YH96W1FT2HV43FS4A1XZ7	2025-02-14 10:02:13.125+00	2025-02-14 10:03:56.977+00	2025-02-14 10:03:56.967+00
variant_01JM1YH985BQN739QSS9YPQVX5	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YH96W1FT2HV43FS4A1XZ7	2025-02-14 10:02:13.125+00	2025-02-14 10:03:56.977+00	2025-02-14 10:03:56.967+00
variant_01JM1YPFVQSF3TEGYNVZ2FJREZ	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YPFTQQAHWNCNFP1G8FGZS	2025-02-14 10:05:03.736+00	2025-02-14 10:20:30.526+00	2025-02-14 10:20:30.512+00
variant_01JM1YPFVQP5E5QK8CKDA30948	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YPFTQQAHWNCNFP1G8FGZS	2025-02-14 10:05:03.736+00	2025-02-14 10:20:30.527+00	2025-02-14 10:20:30.512+00
variant_01JM1YPFVQXDEZKXQTNPFVMZS6	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YPFTQQAHWNCNFP1G8FGZS	2025-02-14 10:05:03.736+00	2025-02-14 10:20:30.527+00	2025-02-14 10:20:30.512+00
variant_01JM1YPFVQPQT4T2T2MMHC6C5W	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YPFTQQAHWNCNFP1G8FGZS	2025-02-14 10:05:03.736+00	2025-02-14 10:20:30.527+00	2025-02-14 10:20:30.512+00
variant_01JM1YPFVQYWAXCD0K0AZB33QG	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1YPFTQQAHWNCNFP1G8FGZS	2025-02-14 10:05:03.736+00	2025-02-14 10:20:30.527+00	2025-02-14 10:20:30.512+00
variant_01JM2DKW971QTV2THPTNZY2NCS	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-9_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-10_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DKW6R5QPTQWZTFEPAZY5V	2025-02-14 14:25:46.792+00	2025-02-14 14:30:35.853+00	2025-02-14 14:30:35.84+00
variant_01JM2DKW97768FBNM9MZQX54Z1	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DKW6R5QPTQWZTFEPAZY5V	2025-02-14 14:25:46.792+00	2025-02-14 14:30:35.853+00	2025-02-14 14:30:35.84+00
variant_01JM1ZKBWG7QS167ZT8SNRFV42	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZKBV6FEBE1G34E5M7TDG6	2025-02-14 10:20:49.936+00	2025-02-14 10:26:16.473+00	2025-02-14 10:26:16.462+00
variant_01JM1ZKBWGWTQHX3H77A2M9FZ7	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZKBV6FEBE1G34E5M7TDG6	2025-02-14 10:20:49.936+00	2025-02-14 10:26:16.473+00	2025-02-14 10:26:16.462+00
variant_01JM1ZKBWGVT3JN20KDKTP5BFK	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZKBV6FEBE1G34E5M7TDG6	2025-02-14 10:20:49.936+00	2025-02-14 10:26:16.473+00	2025-02-14 10:26:16.462+00
variant_01JM1ZKBWGEBCRRW1C2WZ19GF8	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZKBV6FEBE1G34E5M7TDG6	2025-02-14 10:20:49.936+00	2025-02-14 10:26:16.473+00	2025-02-14 10:26:16.462+00
variant_01JM2JKYQNQR247Y18RVTE1GWR	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-modellato-marble", "images": ["//interioricons.com/cdn/shop/files/2028-1_1180x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg?v=1692109644", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg?v=1734001124"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg?v=1734001124&width=1520", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian modellato marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg?v=1734001124&width=760\\n", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg?v=1734001124&width=760\\n", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: #c5c6c3; color: #c5c6c3; background-image: url('//interioricons.com/cdn/shop/files/swatch_modellato.webp?v=1693855061&width=48')", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JKYPA276V6W1PMEFFTQCK	2025-02-14 15:53:12.181+00	2025-02-14 16:01:40.518+00	2025-02-14 16:01:40.509+00
variant_01JM1ZXS89NYGGMYT1WRCYWG1M	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZXS73KBZRW0E30H8EM266	2025-02-14 10:26:31.306+00	2025-02-14 10:32:00.244+00	2025-02-14 10:32:00.227+00
variant_01JM1ZXS89TAA18784E12CNXDA	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZXS73KBZRW0E30H8EM266	2025-02-14 10:26:31.306+00	2025-02-14 10:32:00.244+00	2025-02-14 10:32:00.227+00
variant_01JM1ZXS89YEVDWARBVT65J3KC	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZXS73KBZRW0E30H8EM266	2025-02-14 10:26:31.306+00	2025-02-14 10:32:00.244+00	2025-02-14 10:32:00.227+00
variant_01JM2DKW98BTB970Z1HWERHS53	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DKW6R5QPTQWZTFEPAZY5V	2025-02-14 14:25:46.792+00	2025-02-14 14:30:35.853+00	2025-02-14 14:30:35.84+00
variant_01JM1ZXS89D6JAY45D9H6YEFPG	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZXS73KBZRW0E30H8EM266	2025-02-14 10:26:31.306+00	2025-02-14 10:32:00.244+00	2025-02-14 10:32:00.227+00
variant_01JM1ZXS89650SYC57N3C9DHHM	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM1ZXS73KBZRW0E30H8EM266	2025-02-14 10:26:31.306+00	2025-02-14 10:32:00.244+00	2025-02-14 10:32:00.227+00
variant_01JM2JKYQNSXXS44RHCPNVDQS3	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-white-marble", "images": ["//interioricons.com/cdn/shop/files/1740-1_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-9_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-10_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-11_1180x.jpg?v=1695034459"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-1.jpg?v=1695034459&width=1520", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium white Italian marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-2.jpg?v=1695034459&width=760\\n", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-3.jpg?v=1695034459&width=760\\n", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: ; color: ; background-image: url('//interioricons.com/cdn/shop/files/swatch_marble.gif?v=1693855061&width=48')", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JKYPA276V6W1PMEFFTQCK	2025-02-14 15:53:12.181+00	2025-02-14 16:01:40.519+00	2025-02-14 16:01:40.509+00
variant_01JM2JKYQNY1XXEMVAX6H0PPC6	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-rojo-alicante", "images": ["//interioricons.com/cdn/shop/files/4608-1_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg?v=1721904375", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg?v=1721904376"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg?v=1721904384&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg?v=1721904376&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg?v=1721904376&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: ; color: ; background-image: url('//interioricons.com/cdn/shop/files/swatch_rojo-alicante.jpg?v=1721904954&width=48')", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JKYPA276V6W1PMEFFTQCK	2025-02-14 15:53:12.182+00	2025-02-14 16:01:40.519+00	2025-02-14 16:01:40.509+00
variant_01JM2JKYQNYAFP7PK83XWSH3D3	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-kunis-breccia", "images": ["//interioricons.com/cdn/shop/files/4607-1_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg?v=1721904361", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg?v=1721904360"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: ; color: ; background-image: url('//interioricons.com/cdn/shop/files/swatch_kunis-breccia.jpg?v=1721904913&width=48')", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JKYPA276V6W1PMEFFTQCK	2025-02-14 15:53:12.181+00	2025-02-14 16:01:40.519+00	2025-02-14 16:01:40.509+00
variant_01JM20CSZZC3F3HNGACSK5ZZDA	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM20CSYM758J4KV71BBPEXFZ	2025-02-14 10:34:43.584+00	2025-02-14 10:47:38.657+00	2025-02-14 10:47:38.639+00
variant_01JM20CSZZC2HYXBYDTKC47BM4	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM20CSYM758J4KV71BBPEXFZ	2025-02-14 10:34:43.584+00	2025-02-14 10:47:38.657+00	2025-02-14 10:47:38.639+00
variant_01JM20CSZZHC46F0ZSECDFWEZ0	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM20CSYM758J4KV71BBPEXFZ	2025-02-14 10:34:43.584+00	2025-02-14 10:47:38.657+00	2025-02-14 10:47:38.639+00
variant_01JM20CSZZGFGWDT7KWBZ31VCF	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM20CSYM758J4KV71BBPEXFZ	2025-02-14 10:34:43.584+00	2025-02-14 10:47:38.657+00	2025-02-14 10:47:38.639+00
variant_01JM2C9Y2MB9ZBXXK433Y7QCJM	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-1_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_640x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "https://interioricons.com/cdn/shop/files/4608-1_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_60x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2C9Y1GFHME9JGCVMDW5QQJ	2025-02-14 14:02:52.372+00	2025-02-14 14:15:56.207+00	2025-02-14 14:15:56.19+00
variant_01JM2DKW97MW40WQMJNFE8SH58	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DKW6R5QPTQWZTFEPAZY5V	2025-02-14 14:25:46.792+00	2025-02-14 14:30:35.852+00	2025-02-14 14:30:35.84+00
variant_01JM2C9Y2M2Q1V3DM7ZPEJ36Y9	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-1_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "https://interioricons.com/cdn/shop/files/4609-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2341-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2782-1_280x.jpg", "https://interioricons.com/cdn/shop/files/4609-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2341-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2782-1_280x.jpg", "https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "https://interioricons.com/cdn/shop/files/4607-1_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-12_60x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2C9Y1GFHME9JGCVMDW5QQJ	2025-02-14 14:02:52.372+00	2025-02-14 14:15:56.207+00	2025-02-14 14:15:56.19+00
variant_01JM2C9Y2MS0MRE56F5QAMYF6E	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-1_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "https://interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "https://interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "https://interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "https://interioricons.com/cdn/shop/files/2606-1_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-12_60x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2C9Y1GFHME9JGCVMDW5QQJ	2025-02-14 14:02:52.372+00	2025-02-14 14:15:56.207+00	2025-02-14 14:15:56.19+00
variant_01JM2C9Y2MS6M5HGZM119FAVAT	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "https://interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "https://interioricons.com/cdn/shop/files/1207-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "https://interioricons.com/cdn/shop/files/1207-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_640x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "https://interioricons.com/cdn/shop/files/2028-1_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_60x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg", "https://interioricons.com/cdn/shop/files/5390-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2C9Y1GFHME9JGCVMDW5QQJ	2025-02-14 14:02:52.372+00	2025-02-14 14:15:56.206+00	2025-02-14 14:15:56.19+00
variant_01JM214XJF3BZDB5BQA0BA54VG	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM214XH09Q6V6J76RJN70SWF	2025-02-14 10:47:53.68+00	2025-02-14 10:48:29.902+00	2025-02-14 10:48:29.893+00
variant_01JM214XJF47HSPWFG9JV8GWGD	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM214XH09Q6V6J76RJN70SWF	2025-02-14 10:47:53.68+00	2025-02-14 10:48:29.901+00	2025-02-14 10:48:29.893+00
variant_01JM214XJF9C7WBFN2D3S0GQ37	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM214XH09Q6V6J76RJN70SWF	2025-02-14 10:47:53.68+00	2025-02-14 10:48:29.902+00	2025-02-14 10:48:29.893+00
variant_01JM214XJFMZ7YMH9MAF05AVPK	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM214XH09Q6V6J76RJN70SWF	2025-02-14 10:47:53.68+00	2025-02-14 10:48:29.902+00	2025-02-14 10:48:29.893+00
variant_01JM214XJFTMSG53R69YR1HBBJ	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM214XH09Q6V6J76RJN70SWF	2025-02-14 10:47:53.68+00	2025-02-14 10:48:29.902+00	2025-02-14 10:48:29.893+00
variant_01JM2C9Y2MSRJ4XZEP0P757DXV	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-1_640x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_640x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_640x.jpg", "https://interioricons.com/cdn/shop/files/1740-1_60x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_60x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_60x.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2C9Y1GFHME9JGCVMDW5QQJ	2025-02-14 14:02:52.372+00	2025-02-14 14:15:56.207+00	2025-02-14 14:15:56.19+00
variant_01JM2DKW98YK271PCVXJMF1KR4	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DKW6R5QPTQWZTFEPAZY5V	2025-02-14 14:25:46.792+00	2025-02-14 14:30:35.853+00	2025-02-14 14:30:35.84+00
variant_01JM2JKYQNZMT91TK6EG17D5JH	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-rosso-levanto-marble", "images": ["//interioricons.com/cdn/shop/files/2606-1_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg?v=1712839910", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg?v=1712839909"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg?v=1738857680&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian Rosso Levanto marble with striking white veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg?v=1738857680&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg?v=1738857680&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: ; color: ; background-image: url('//interioricons.com/cdn/shop/files/swatch_rosso-levanto.jpg?v=1711462499&width=48')", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JKYPA276V6W1PMEFFTQCK	2025-02-14 15:53:12.181+00	2025-02-14 16:01:40.519+00	2025-02-14 16:01:40.509+00
variant_01JM216BSV5TBZ324ZGN3S211G	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM216BRNW43T5W3PVRFQ3JQM	2025-02-14 10:48:41.019+00	2025-02-14 13:52:56.946+00	2025-02-14 13:52:56.935+00
variant_01JM216BSV8VX7G86TQJV8BMK8	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM216BRNW43T5W3PVRFQ3JQM	2025-02-14 10:48:41.019+00	2025-02-14 13:52:56.946+00	2025-02-14 13:52:56.935+00
variant_01JM216BSV96MQJBFQRQJHK1CN	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-1_640x.jpg", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-2_640x.jpg", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "//interioricons.com/cdn/shop/files/1740-3_640x.jpg", "//interioricons.com/cdn/shop/files/1740-1_60x.jpg", "//interioricons.com/cdn/shop/files/1740-2_60x.jpg", "//interioricons.com/cdn/shop/files/1740-3_60x.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM216BRNW43T5W3PVRFQ3JQM	2025-02-14 10:48:41.019+00	2025-02-14 13:52:56.946+00	2025-02-14 13:52:56.935+00
variant_01JM216BSVGC0REJX7DN9EHS1H	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM216BRNW43T5W3PVRFQ3JQM	2025-02-14 10:48:41.019+00	2025-02-14 13:52:56.946+00	2025-02-14 13:52:56.935+00
variant_01JM216BSVGFZBBP5NPYA769QS	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/rollover_1628_9720aae3-0741-4851-be56-696adfc103b8_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM216BRNW43T5W3PVRFQ3JQM	2025-02-14 10:48:41.019+00	2025-02-14 13:52:56.946+00	2025-02-14 13:52:56.935+00
variant_01JM2K3ZSC3JK012FDYS2GD146	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-modellato-marble", "images": ["//interioricons.com/cdn/shop/files/2028-1_1180x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg?v=1692109644", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg?v=1734001124"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg?v=1734001124&width=1520", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian modellato marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg?v=1734001124&width=760\\n", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg?v=1734001124&width=760\\n", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: #c5c6c3; color: #c5c6c3; background-image: url('//interioricons.com/cdn/shop/files/swatch_modellato.webp?v=1693855061&width=48')", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH	2025-02-14 16:01:57.549+00	2025-02-14 16:01:57.549+00	\N
variant_01JM2K3ZSDXRS6ED0N6TJAE31K	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-white-marble", "images": ["//interioricons.com/cdn/shop/files/1740-1_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-9_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-10_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-11_1180x.jpg?v=1695034459"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-1.jpg?v=1695034459&width=1520", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium white Italian marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-2.jpg?v=1695034459&width=760\\n", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-3.jpg?v=1695034459&width=760\\n", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: ; color: ; background-image: url('//interioricons.com/cdn/shop/files/swatch_marble.gif?v=1693855061&width=48')", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH	2025-02-14 16:01:57.549+00	2025-02-14 16:01:57.549+00	\N
variant_01JM2BQZF61QEEJFQBR749C109	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-2_640x.jpg", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-3_640x.jpg", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-4_640x.jpg", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-10_640x.jpg", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-11_640x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "//interioricons.com/cdn/shop/files/1207-1_280x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "//interioricons.com/cdn/shop/files/2028-13_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/2028-1_60x.jpg", "//interioricons.com/cdn/shop/files/2028-2_60x.jpg", "//interioricons.com/cdn/shop/files/2028-3_60x.jpg", "//interioricons.com/cdn/shop/files/2028-4_60x.jpg", "//interioricons.com/cdn/shop/files/2028-10_60x.jpg", "//interioricons.com/cdn/shop/files/2028-11_60x.jpg", "//interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "//interioricons.com/cdn/shop/files/2028-13_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg", "//interioricons.com/cdn/shop/files/5390-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2BQZDYMD186EYYK52YZXXR	2025-02-14 13:53:03.974+00	2025-02-14 13:54:50.836+00	2025-02-14 13:54:50.821+00
variant_01JM2BQZF637WXD2W0KYY79C75	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-1_640x.jpg", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-2_640x.jpg", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-3_640x.jpg", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-4_640x.jpg", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-5_640x.jpg", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-10_640x.jpg", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4607-11_640x.jpg", "//interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4609-1_280x.jpg", "//interioricons.com/cdn/shop/files/2341-1_280x.jpg", "//interioricons.com/cdn/shop/files/2782-1_280x.jpg", "//interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/4607-1_60x.jpg", "//interioricons.com/cdn/shop/files/4607-2_60x.jpg", "//interioricons.com/cdn/shop/files/4607-3_60x.jpg", "//interioricons.com/cdn/shop/files/4607-4_60x.jpg", "//interioricons.com/cdn/shop/files/4607-5_60x.jpg", "//interioricons.com/cdn/shop/files/4607-10_60x.jpg", "//interioricons.com/cdn/shop/files/4607-11_60x.jpg", "//interioricons.com/cdn/shop/files/4607-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2BQZDYMD186EYYK52YZXXR	2025-02-14 13:53:03.974+00	2025-02-14 13:54:50.836+00	2025-02-14 13:54:50.821+00
variant_01JM2BQZF6C291VX9TQTBMJWAF	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-1_640x.jpg", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-2_640x.jpg", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-3_640x.jpg", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-4_640x.jpg", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-10_640x.jpg", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "//interioricons.com/cdn/shop/files/2606-11_640x.jpg", "//interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "//interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/2606-1_60x.jpg", "//interioricons.com/cdn/shop/files/2606-2_60x.jpg", "//interioricons.com/cdn/shop/files/2606-3_60x.jpg", "//interioricons.com/cdn/shop/files/2606-4_60x.jpg", "//interioricons.com/cdn/shop/files/2606-10_60x.jpg", "//interioricons.com/cdn/shop/files/2606-11_60x.jpg", "//interioricons.com/cdn/shop/files/2606-12_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2BQZDYMD186EYYK52YZXXR	2025-02-14 13:53:03.974+00	2025-02-14 13:54:50.836+00	2025-02-14 13:54:50.821+00
variant_01JM2BQZF6H12ZVV0E74KYHT7G	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "//interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-1_640x.jpg", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-2_640x.jpg", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-3_640x.jpg", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-4_640x.jpg", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-5_640x.jpg", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-10_640x.jpg", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "//interioricons.com/cdn/shop/files/4608-11_640x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/4608-1_60x.jpg", "//interioricons.com/cdn/shop/files/4608-2_60x.jpg", "//interioricons.com/cdn/shop/files/4608-3_60x.jpg", "//interioricons.com/cdn/shop/files/4608-4_60x.jpg", "//interioricons.com/cdn/shop/files/4608-5_60x.jpg", "//interioricons.com/cdn/shop/files/4608-10_60x.jpg", "//interioricons.com/cdn/shop/files/4608-11_60x.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "//interioricons.com/cdn/shop/files/2184-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "//interioricons.com/cdn/shop/files/2149-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "//interioricons.com/cdn/shop/files/2028-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "//interioricons.com/cdn/shop/files/1635-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "//interioricons.com/cdn/shop/files/2333-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "//interioricons.com/cdn/shop/files/1738-5_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "//interioricons.com/cdn/shop/files/1739-3_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "//interioricons.com/cdn/shop/files/2218-2_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "//interioricons.com/cdn/shop/files/2727-1_640x.jpg", "//interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "//interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2BQZDYMD186EYYK52YZXXR	2025-02-14 13:53:03.974+00	2025-02-14 13:54:50.836+00	2025-02-14 13:54:50.821+00
variant_01JM2D2W2QCD75KAAM48R130RA	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_640x.jpg", "https://interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_425x_crop_center.jpg", "https://interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "https://interioricons.com/cdn/shop/files/1207-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2275-3_f75d55f3-6afc-441a-b63f-958ed8dadaae_280x.jpg", "https://interioricons.com/cdn/shop/files/1207-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_640x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "https://interioricons.com/cdn/shop/files/2028-1_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-12_3666fb12-dd53-4dc9-b956-e99802fc08c9_60x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_60x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg", "https://interioricons.com/cdn/shop/files/5390-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2D2W0CNQT5B7Y7ATY88HE7	2025-02-14 14:16:29.528+00	2025-02-14 14:25:36.805+00	2025-02-14 14:25:36.789+00
variant_01JM2D2W2R16MX5C90J1BZ7F1J	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-1_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_640x.jpg", "https://interioricons.com/cdn/shop/files/2606-12_425x_crop_center.jpg", "https://interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "https://interioricons.com/cdn/shop/files/2024-1_4be2f6c0-b7d0-4411-9371-6ab5dce6ea3f_280x.jpg", "https://interioricons.com/cdn/shop/files/2606-12_1180x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "https://interioricons.com/cdn/shop/files/2606-1_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_60x.jpg", "https://interioricons.com/cdn/shop/files/2606-12_60x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2D2W0CNQT5B7Y7ATY88HE7	2025-02-14 14:16:29.528+00	2025-02-14 14:25:36.805+00	2025-02-14 14:25:36.789+00
variant_01JM2D2W2RF1VB5677E6XKYJR3	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-1_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_640x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_640x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "https://interioricons.com/cdn/shop/files/4608-1_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_60x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_60x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2D2W0CNQT5B7Y7ATY88HE7	2025-02-14 14:16:29.528+00	2025-02-14 14:25:36.805+00	2025-02-14 14:25:36.789+00
variant_01JM2D2W2RSXGB04NSARFHNR8J	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/rollover_1989_1_1.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_2068-1_0e142514-fa0e-4288-b470-3a2d565a9adb.png", "https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-1_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_640x.jpg", "https://interioricons.com/cdn/shop/files/4607-12_425x_crop_center.jpg", "https://interioricons.com/cdn/shop/files/4609-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2341-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2782-1_280x.jpg", "https://interioricons.com/cdn/shop/files/4609-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2341-1_280x.jpg", "https://interioricons.com/cdn/shop/files/2782-1_280x.jpg", "https://interioricons.com/cdn/shop/files/4607-12_1180x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "https://interioricons.com/cdn/shop/files/4607-1_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_60x.jpg", "https://interioricons.com/cdn/shop/files/4607-12_60x.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "https://interioricons.com/cdn/shop/files/2184-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2184_large.jpg", "https://interioricons.com/cdn/shop/files/2149-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2149_large.jpg", "https://interioricons.com/cdn/shop/files/2028-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2028_b9fb6e5c-7723-4c0b-b801-6db1d549c29e_large.jpg", "https://interioricons.com/cdn/shop/files/1635-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1635_large.jpg", "https://interioricons.com/cdn/shop/files/2333-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2333_large.jpg", "https://interioricons.com/cdn/shop/files/1738-5_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1738_large.jpg", "https://interioricons.com/cdn/shop/files/1739-3_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_1739_large.jpg", "https://interioricons.com/cdn/shop/files/2218-2_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2218_large.jpg", "https://interioricons.com/cdn/shop/files/2727-1_640x.jpg", "https://interioricons.com/cdn/shop/files/rollover_2727_large.jpg", "https://interioricons.com/cdn/shop/files/5850-1_640x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2D2W0CNQT5B7Y7ATY88HE7	2025-02-14 14:16:29.528+00	2025-02-14 14:25:36.805+00	2025-02-14 14:25:36.789+00
variant_01JM2K3ZSD4MM311EXN487TMX6	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-rosso-levanto-marble", "images": ["//interioricons.com/cdn/shop/files/2606-1_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg?v=1712839910", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg?v=1712839909"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg?v=1738857680&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian Rosso Levanto marble with striking white veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg?v=1738857680&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg?v=1738857680&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: ; color: ; background-image: url('//interioricons.com/cdn/shop/files/swatch_rosso-levanto.jpg?v=1711462499&width=48')", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH	2025-02-14 16:01:57.549+00	2025-02-14 16:01:57.549+00	\N
variant_01JM2DWYKE0PGCT07XFQ88R40Z	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DWYH6WWGWX4SJYBCDP3ND	2025-02-14 14:30:44.079+00	2025-02-14 14:33:33.719+00	2025-02-14 14:33:33.708+00
variant_01JM2DWYKE5W4F9GCHS7TT2E0K	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DWYH6WWGWX4SJYBCDP3ND	2025-02-14 14:30:44.079+00	2025-02-14 14:33:33.719+00	2025-02-14 14:33:33.708+00
variant_01JM2DWYKEBJYSHGY3RBZCZHF1	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DWYH6WWGWX4SJYBCDP3ND	2025-02-14 14:30:44.079+00	2025-02-14 14:33:33.719+00	2025-02-14 14:33:33.708+00
variant_01JM2DWYKEH2R0T1VEWF5BBG02	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-9_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-10_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DWYH6WWGWX4SJYBCDP3ND	2025-02-14 14:30:44.079+00	2025-02-14 14:33:33.719+00	2025-02-14 14:33:33.708+00
variant_01JM2DWYKFQ444FG22NHQ7E02Q	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2DWYH6WWGWX4SJYBCDP3ND	2025-02-14 14:30:44.079+00	2025-02-14 14:33:33.719+00	2025-02-14 14:33:33.708+00
variant_01JM2K3ZSDF0SD3GRCA3ZJMFS2	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-kunis-breccia", "images": ["//interioricons.com/cdn/shop/files/4607-1_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg?v=1721904361", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg?v=1721904360"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: ; color: ; background-image: url('//interioricons.com/cdn/shop/files/swatch_kunis-breccia.jpg?v=1721904913&width=48')", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH	2025-02-14 16:01:57.549+00	2025-02-14 16:01:57.549+00	\N
variant_01JM2K3ZSD3B6MS40VCPVRDWAJ	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-rojo-alicante", "images": ["//interioricons.com/cdn/shop/files/4608-1_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg?v=1721904375", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg?v=1721904376"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg?v=1721904384&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg?v=1721904376&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg?v=1721904376&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "swatchStyle": "background-color: ; color: ; background-image: url('//interioricons.com/cdn/shop/files/swatch_rojo-alicante.jpg?v=1721904954&width=48')", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2K3ZQ4Q2S8MT5VRKB5AKEH	2025-02-14 16:01:57.549+00	2025-02-14 16:01:57.549+00	\N
variant_01JM2E2AWJ4MKAEG44N751P1V4	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-9_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-10_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2E2AT36CVJX97E35K089W8	2025-02-14 14:33:40.499+00	2025-02-14 14:43:26.77+00	2025-02-14 14:43:26.757+00
variant_01JM2E2AWJK67P0V6687Y9XDWK	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2E2AT36CVJX97E35K089W8	2025-02-14 14:33:40.499+00	2025-02-14 14:43:26.77+00	2025-02-14 14:43:26.757+00
variant_01JM2E2AWK5GRK72NAP1CZMYZV	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2E2AT36CVJX97E35K089W8	2025-02-14 14:33:40.499+00	2025-02-14 14:43:26.77+00	2025-02-14 14:43:26.757+00
variant_01JM2E2AWKFZ9ZSSPZ9782C4AJ	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2E2AT36CVJX97E35K089W8	2025-02-14 14:33:40.499+00	2025-02-14 14:43:26.77+00	2025-02-14 14:43:26.757+00
variant_01JM2E2AWKZJ0GD6SE7J9T6Y01	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2E2AT36CVJX97E35K089W8	2025-02-14 14:33:40.499+00	2025-02-14 14:43:26.77+00	2025-02-14 14:43:26.757+00
variant_01JM2EME8J4YT0973E3MC37691	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian Rosso Levanto marble with striking white veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2EME6DXF5EBNHSCGDK6AR8	2025-02-14 14:43:33.779+00	2025-02-14 15:36:51.61+00	2025-02-14 15:36:51.594+00
variant_01JM2EME8J4Z2T3QWBPMV2J05B	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-9_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-10_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-1.jpg", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium white Italian marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-2.jpg", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-3.jpg", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2EME6DXF5EBNHSCGDK6AR8	2025-02-14 14:43:33.779+00	2025-02-14 15:36:51.61+00	2025-02-14 15:36:51.594+00
variant_01JM2EME8J7YV9ZSM3S87RE2F1	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian modellato marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2EME6DXF5EBNHSCGDK6AR8	2025-02-14 14:43:33.779+00	2025-02-14 15:36:51.61+00	2025-02-14 15:36:51.594+00
variant_01JM2EME8J8DDQ5TBX8QJD33FA	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2EME6DXF5EBNHSCGDK6AR8	2025-02-14 14:43:33.779+00	2025-02-14 15:36:51.61+00	2025-02-14 15:36:51.594+00
variant_01JM2EME8JVG0NZC9HTGKA03M2	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2EME6DXF5EBNHSCGDK6AR8	2025-02-14 14:43:33.779+00	2025-02-14 15:36:51.61+00	2025-02-14 15:36:51.594+00
variant_01JM2HQQ7GHZ1ZA6GKAC1Q8ZED	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4608-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4608-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC	2025-02-14 15:37:46.993+00	2025-02-14 15:39:13.476+00	2025-02-14 15:39:13.463+00
variant_01JM2HQQ7GJXZ171DBF284Q60W	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/1740-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/1740-3_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-9_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-10_1180x.jpg", "https://interioricons.com/cdn/shop/products/1740-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-1.jpg", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium white Italian marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-2.jpg", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-3.jpg", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC	2025-02-14 15:37:46.993+00	2025-02-14 15:39:13.476+00	2025-02-14 15:39:13.463+00
variant_01JM2HTJ6V33M12JK6F611PAM7	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/1740-1_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-9_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-10_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-11_1180x.jpg?v=1695034459"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-1.jpg", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium white Italian marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-2.jpg", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/products/lifestyle_1740-3.jpg", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HTJ546FNVY2DCHXWX5R7V	2025-02-14 15:39:20.156+00	2025-02-14 15:42:36.546+00	2025-02-14 15:42:36.535+00
variant_01JM2HQQ7GRSAFCJNWT0B6JQ81	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/4607-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-5_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/4607-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC	2025-02-14 15:37:46.993+00	2025-02-14 15:39:13.476+00	2025-02-14 15:39:13.463+00
variant_01JM2HQQ7GWGG9VH5FY6YQQ3QR	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2606-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2606-11_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian Rosso Levanto marble with striking white veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC	2025-02-14 15:37:46.993+00	2025-02-14 15:39:13.476+00	2025-02-14 15:39:13.463+00
variant_01JM2HQQ7GXSRWQQ32FJKGK0KK	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["https://interioricons.com/cdn/shop/files/2028-1_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-2_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-3_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-4_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-10_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-11_1180x.jpg", "https://interioricons.com/cdn/shop/files/2028-13_1180x.jpg"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian modellato marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HQQ4VSP0SAZB0BSS7MSMC	2025-02-14 15:37:46.993+00	2025-02-14 15:39:13.476+00	2025-02-14 15:39:13.463+00
variant_01JM2HTJ6V2V12P1XC3H0PB4DH	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/2606-1_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg?v=1712839910", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg?v=1712839909"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian Rosso Levanto marble with striking white veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HTJ546FNVY2DCHXWX5R7V	2025-02-14 15:39:20.156+00	2025-02-14 15:42:36.547+00	2025-02-14 15:42:36.535+00
variant_01JM2HTJ6V7G3AGXW9G8M8Z6J7	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/2028-1_1180x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg?v=1692109644", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg?v=1734001124"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian modellato marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HTJ546FNVY2DCHXWX5R7V	2025-02-14 15:39:20.156+00	2025-02-14 15:42:36.546+00	2025-02-14 15:42:36.535+00
variant_01JM2HTJ6W79908PTH99SR3NSH	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/4607-1_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg?v=1721904361", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg?v=1721904360"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HTJ546FNVY2DCHXWX5R7V	2025-02-14 15:39:20.156+00	2025-02-14 15:42:36.547+00	2025-02-14 15:42:36.535+00
variant_01JM2HTJ6WFMRW5HQFQQ64D5WD	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/4608-1_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg?v=1721904375", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg?v=1721904376"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "https://interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2HTJ546FNVY2DCHXWX5R7V	2025-02-14 15:39:20.156+00	2025-02-14 15:42:36.547+00	2025-02-14 15:42:36.535+00
variant_01JM2J0QEEAWYPCC2MSNWPPYS6	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/1740-1_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-9_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-10_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-11_1180x.jpg?v=1695034459"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-1.jpg?v=1695034459&width=1520", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium white Italian marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-2.jpg?v=1695034459&width=760\\n", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-3.jpg?v=1695034459&width=760\\n", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2J0QCVT5C2W5CE36Y8YVN3	2025-02-14 15:42:42.126+00	2025-02-14 15:49:16.225+00	2025-02-14 15:49:16.213+00
variant_01JM2J0QEED1E9A2RT6VJC3P3J	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/4607-1_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg?v=1721904361", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg?v=1721904360"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2J0QCVT5C2W5CE36Y8YVN3	2025-02-14 15:42:42.126+00	2025-02-14 15:49:16.225+00	2025-02-14 15:49:16.213+00
variant_01JM2J0QEEH73GY3FCSJD39RGV	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/2606-1_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg?v=1712839910", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg?v=1712839909"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg?v=1738857680&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian Rosso Levanto marble with striking white veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg?v=1738857680&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg?v=1738857680&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2J0QCVT5C2W5CE36Y8YVN3	2025-02-14 15:42:42.126+00	2025-02-14 15:49:16.225+00	2025-02-14 15:49:16.213+00
variant_01JM2J0QEENMCCAYY13QY5W8GP	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/2028-1_1180x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg?v=1692109644", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg?v=1734001124"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg?v=1734001124&width=1520", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian modellato marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg?v=1734001124&width=760\\n", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg?v=1734001124&width=760\\n", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2J0QCVT5C2W5CE36Y8YVN3	2025-02-14 15:42:42.126+00	2025-02-14 15:49:16.225+00	2025-02-14 15:49:16.213+00
variant_01JM2J0QEER0962YW0Z7FAR8VE	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"images": ["//interioricons.com/cdn/shop/files/4608-1_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg?v=1721904375", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg?v=1721904376"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg?v=1721904384&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg?v=1721904376&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg?v=1721904376&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2J0QCVT5C2W5CE36Y8YVN3	2025-02-14 15:42:42.126+00	2025-02-14 15:49:16.225+00	2025-02-14 15:49:16.213+00
variant_01JM2JD0032G9NX9JVS5P9G7KG	Plinth - White Marble	1740	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-white-marble", "images": ["//interioricons.com/cdn/shop/files/1740-1_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-2_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/files/1740-3_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-9_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-10_1180x.jpg?v=1695034459", "//interioricons.com/cdn/shop/products/1740-11_1180x.jpg?v=1695034459"], "weight": "300 lbs", "assembly": "None required", "material": "Polished white marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-1.jpg?v=1695034459&width=1520", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium white Italian marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-2.jpg?v=1695034459&width=760\\n", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/products/lifestyle_1740-3.jpg?v=1695034459&width=760\\n", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "1740", "Material": "Polished white marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JCZYKS64JW7AHA5KDNWHY	2025-02-14 15:49:24.1+00	2025-02-14 15:52:47.595+00	2025-02-14 15:52:47.583+00
variant_01JM2JD003PJTFMXYF8PMW04V1	Plinth - Modellato Marble	2028	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-modellato-marble", "images": ["//interioricons.com/cdn/shop/files/2028-1_1180x.jpg?v=1692109643", "//interioricons.com/cdn/shop/files/2028-2_1180x.jpg?v=1692109644", "//interioricons.com/cdn/shop/files/2028-3_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-4_1180x.jpg?v=1692109642", "//interioricons.com/cdn/shop/files/2028-10_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-11_1180x.jpg?v=1692109653", "//interioricons.com/cdn/shop/files/2028-13_1180x.jpg?v=1734001124"], "weight": "300 lbs", "assembly": "None required", "material": "Modellato Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-1_9bbc4763-c2ff-4428-b29e-1d03570d86a1.jpg?v=1734001124&width=1520", "title": "Beauty Takes Shape", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian modellato marble with subtle, elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-2.jpg?v=1734001124&width=760\\n", "title": "Monolithic Masterpiece", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2028-3.jpg?v=1734001124&width=760\\n", "title": "Luxe Marble", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2028", "Material": "Modellato Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JCZYKS64JW7AHA5KDNWHY	2025-02-14 15:49:24.1+00	2025-02-14 15:52:47.595+00	2025-02-14 15:52:47.583+00
variant_01JM2JD003RMCN6H3G57WB99B1	Plinth - Rosso Levanto Marble	2606	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-rosso-levanto-marble", "images": ["//interioricons.com/cdn/shop/files/2606-1_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-2_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-3_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-4_1180x.jpg?v=1712839909", "//interioricons.com/cdn/shop/files/2606-10_1180x.jpg?v=1712839910", "//interioricons.com/cdn/shop/files/2606-11_1180x.jpg?v=1712839909"], "weight": "300 lbs", "assembly": "None required", "material": "Rosso Levanto Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-1_63de0315-1a3b-46c0-a2a1-e69870f2b7d8.jpg?v=1738857680&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium Italian Rosso Levanto marble with striking white veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-2.jpg?v=1738857680&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_2606-3.jpg?v=1738857680&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "2606", "Material": "Rosso Levanto Marble", "Product Weight": "300 lbs", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JCZYKS64JW7AHA5KDNWHY	2025-02-14 15:49:24.1+00	2025-02-14 15:52:47.595+00	2025-02-14 15:52:47.583+00
variant_01JM2JD004DHSD3R5XVVDQYAY4	Plinth - Rojo Alicante	4608	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-rojo-alicante", "images": ["//interioricons.com/cdn/shop/files/4608-1_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-2_1180x.jpg?v=1721904375", "//interioricons.com/cdn/shop/files/4608-3_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-4_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-5_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-10_1180x.jpg?v=1721904376", "//interioricons.com/cdn/shop/files/4608-11_1180x.jpg?v=1721904376"], "weight": "300 lbs", "assembly": "None required", "material": "Rojo Alicante Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-1.jpg?v=1721904384&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-2.jpg?v=1721904376&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4608-3.jpg?v=1721904376&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4608", "Material": "Rojo Alicante Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "shippingCartons": "1", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JCZYKS64JW7AHA5KDNWHY	2025-02-14 15:49:24.1+00	2025-02-14 15:52:47.595+00	2025-02-14 15:52:47.583+00
variant_01JM2JD004FW0X9KYT2HFAR4B2	Plinth - Kunis Breccia	4607	\N	\N	\N	f	t	\N	\N	\N	\N	\N	\N	\N	\N	{"handle": "plinth-coffee-table-kunis-breccia", "images": ["//interioricons.com/cdn/shop/files/4607-1_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-2_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-3_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-4_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-5_1180x.jpg?v=1721904360", "//interioricons.com/cdn/shop/files/4607-10_1180x.jpg?v=1721904361", "//interioricons.com/cdn/shop/files/4607-11_1180x.jpg?v=1721904360"], "weight": "300 lbs", "assembly": "None required", "material": "Kunis Breccia Marble", "dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "highlights": [{"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-1_c2835937-dc97-475e-b3c7-76ca0f5ab6d6.jpg?v=1722006767&width=1520", "title": "BEAUTY TAKES SHAPE", "content": "Perfectly uniform in shape, this monolithic design is an homage to the exquisite natural character of the stone. Made from premium marble with elegant veining, each Plinth coffee will be unique, bearing the distinctive characteristics that were rendered into this beautiful stone over hundreds of years."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-2.jpg?v=1721904360&width=760\\n", "title": "MONOLITHIC MASTERPIECE", "content": "Taking the conventional idea of a plinth and flipping it on its head, this sophisticated contemporary design is not just a podium on which to display or a functional piece of furniture, but a captivating sculptural piece in its own right."}, {"image": "//interioricons.com/cdn/shop/files/lifestyle_4607-3.jpg?v=1721904361&width=760\\n", "title": "LUXE MARBLE", "content": "Thanks to the timeless appeal and refined aesthetic of natural marble, the Plinth is at home in both contemporary and heritage spaces. Allow this striking piece to become the focal point of your space, and the most stylish place to rest your glass and favorite coffee table books."}], "specifications": {"SKU": "4607", "Material": "Kunis Breccia Marble", "Product Weight": "300 lbs", "Tabletop Height": "12\\"", "Material Details": "Marble is sealed, making it weather resistant and suitable for outdoor use", "Product Dimensions": "H11.8\\" x W39.4\\" x D23.6\\"", "Tabletop Thickness": "0.7\\" marble over concrete composite core", "Packaging Dimensions": "43\\" x 27\\" x 16\\" (300 lbs)", "Assembly Requirements": "None required", "Indoor or Outdoor Use": "Suitable for both indoor and outdoor use", "No. of Shipping Cartons": "1"}, "tabletopHeight": "12\\"", "materialDetails": "Marble is sealed, making it weather resistant and suitable for outdoor use", "shippingCartons": "1", "indoorOutdoorUse": "Suitable for both indoor and outdoor use", "tabletopThickness": "0.7\\" marble over concrete composite core", "packagingDimensions": "43\\" x 27\\" x 16\\" (300 lbs)"}	0	prod_01JM2JCZYKS64JW7AHA5KDNWHY	2025-02-14 15:49:24.1+00	2025-02-14 15:52:47.595+00	2025-02-14 15:52:47.583+00
\.


--
-- Data for Name: product_variant_inventory_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variant_inventory_item (variant_id, inventory_item_id, id, required_quantity, created_at, updated_at, deleted_at) FROM stdin;
variant_01JM18DSNACS3GXYYB39GFMKPX	iitem_01JM18DSNXGVYGSFT40FYHFTWY	pvitem_01JM18DSPB957776PM0Z7696SA	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNBYTFQ1NCE20H3ZSQ8	iitem_01JM18DSNX8DN8MRK5ABBNH427	pvitem_01JM18DSPC98026R6TTZKKZN3M	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNBZ7305PJ1BB16B7NJ	iitem_01JM18DSNXWPGJ5E5AFAGDSVQ1	pvitem_01JM18DSPCVNT3NW3HP5D2H9AM	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNBKGQBK8MTNPBP4WGK	iitem_01JM18DSNXB1DPXN7DYPGJC496	pvitem_01JM18DSPCFVEG9ZDRMK08B4ES	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNBBW851G7XADR5Y11G	iitem_01JM18DSNXDX2HJGQCZ2KRMKEB	pvitem_01JM18DSPC581MAKD1BQTZ0R4F	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNBJ6MZ96S8DFKTCTJZ	iitem_01JM18DSNXPPR64514GA3NCXP2	pvitem_01JM18DSPCBS1Q56WQ8DJH6YE5	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNB55W3XDMBK0Y8QWD6	iitem_01JM18DSNXXJHSK3910WCHE5X5	pvitem_01JM18DSPCNQSMCSR8RZ9DNCWT	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNBRM5FFHXBTZ8DYG8D	iitem_01JM18DSNXZCQ4M0JMYN9KDQ08	pvitem_01JM18DSPC6TCSS02NFZ97V6E7	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNBCP10KK5FM55NC1P6	iitem_01JM18DSNXNV1A9YJZ0VQN51HH	pvitem_01JM18DSPC7N8GYRBZMRKSN59S	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNB6TMM157AD54G8JNK	iitem_01JM18DSNX548SXS80XKZP70PG	pvitem_01JM18DSPCMET566KHKZ6AJGWN	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNBQEC5YPHMEF90YH6V	iitem_01JM18DSNX0MR6QKFBWGYT74CS	pvitem_01JM18DSPCFJJYD81ASM5KENV8	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNC9CH6Y05WGBSF2P7A	iitem_01JM18DSNXCY2A425R2TEV06DK	pvitem_01JM18DSPC8JTFZQ56YDP3258N	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNCWH0FSR51J3GMP2J5	iitem_01JM18DSNXDJ3DBKVRR98193Z5	pvitem_01JM18DSPC6VEC3Q35AQWTZEJC	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNC9YD7MY1RS24BRRAN	iitem_01JM18DSNXZSTM0CD4DQJBDER2	pvitem_01JM18DSPC56ZP680MYT93CDWB	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNCJWHT8XE7NW8GR0P3	iitem_01JM18DSNXV4H3VF5Z6W7288RF	pvitem_01JM18DSPC498F35H8ASACWBXS	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNC978BYBNCGC6MNCCJ	iitem_01JM18DSNXXAS1420HKS7W1P05	pvitem_01JM18DSPC6R706NAF9WPFRFKM	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNCMPAPM2E7A096B2JY	iitem_01JM18DSNYQK5HYFNBS7HRHBSR	pvitem_01JM18DSPCJ444MXF02SQD5ADK	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNCW8Q9A9TFMFYNBX2C	iitem_01JM18DSNYVHEN4FFM6W245XFV	pvitem_01JM18DSPCXDTAK1BJHDTP2ART	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNC0VTDG213TNW0YMKJ	iitem_01JM18DSNYQ0P1VJRV0JX0TCF8	pvitem_01JM18DSPCSRF97R4THX1NW4QH	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM18DSNCDA0YH5QGTSY5KKTY	iitem_01JM18DSNYYW8T348NPGE7JPS7	pvitem_01JM18DSPD1VQHHM7YK9SPGXC7	1	2025-02-14 03:35:50.218682+00	2025-02-14 03:35:50.218682+00	\N
variant_01JM1E0C0N5YP45XWKT9FEZMZ8	iitem_01JM1E0C1HPPDZNMSX9CFTFP4Z	pvitem_01JM1E0C1Z05GZR96937WM7712	1	2025-02-14 05:13:21.727568+00	2025-02-14 05:14:37.64+00	2025-02-14 05:14:37.64+00
variant_01JM1E0C0N5VRYBWD3WP9X5QHA	iitem_01JM1E0C1H288SKQ2PEHW3DVB5	pvitem_01JM1E0C20TM9Y1Z2JAHHGV204	1	2025-02-14 05:13:21.727568+00	2025-02-14 05:14:37.64+00	2025-02-14 05:14:37.64+00
variant_01JM1E0C0NY8EENH3GJ708M5WP	iitem_01JM1E0C1JYH4EFTJC2Y2ZWFJR	pvitem_01JM1E0C204J6FJYTQ2JRKHJS7	1	2025-02-14 05:13:21.727568+00	2025-02-14 05:14:37.64+00	2025-02-14 05:14:37.64+00
variant_01JM1E0C0N8K92B4ZSE30JT615	iitem_01JM1E0C1JPCS89ESXKX9DDR7G	pvitem_01JM1E0C20378R70CABNP4D6VV	1	2025-02-14 05:13:21.727568+00	2025-02-14 05:14:37.64+00	2025-02-14 05:14:37.64+00
variant_01JM1E0C0N5G5927E2G2VBRX63	iitem_01JM1E0C1JR6J4FAV5CH0J2WDW	pvitem_01JM1E0C20008DM66N40SG40VM	1	2025-02-14 05:13:21.727568+00	2025-02-14 05:14:37.64+00	2025-02-14 05:14:37.64+00
variant_01JM1E0C0NF88ZPW5JD3SCZ186	iitem_01JM1E0C1JCZPMBCVJJD2R9FYB	pvitem_01JM1E0C2014BDE6Z0YZZG6C4A	1	2025-02-14 05:13:21.727568+00	2025-02-14 05:14:37.64+00	2025-02-14 05:14:37.64+00
variant_01JM1E0C0P7G25GVZ4X3QT2GCJ	iitem_01JM1E0C1JXMPQY6FZ5BSF0C7F	pvitem_01JM1E0C2021F4YCJSTQ6QJJZF	1	2025-02-14 05:13:21.727568+00	2025-02-14 05:14:37.64+00	2025-02-14 05:14:37.64+00
variant_01JM1E0C0PGGR2N4YVX50M38BJ	iitem_01JM1E0C1J5FYBMZQQ22N8TQQ5	pvitem_01JM1E0C20BTHYN0VET0MTYT3Y	1	2025-02-14 05:13:21.727568+00	2025-02-14 05:14:37.64+00	2025-02-14 05:14:37.64+00
variant_01JM1X4XTQQBG6VK83CSAY1GRR	iitem_01JM1X4XVRZCC06X1TNXD6S38M	pvitem_01JM1X4XW6QW158NWYEP7DRHX5	1	2025-02-14 09:37:59.686021+00	2025-02-14 09:44:51.658+00	2025-02-14 09:44:51.658+00
variant_01JM1X4XTQ34CBRGMYFCNA4GMR	iitem_01JM1X4XVR4254F1VTVJWTCSTW	pvitem_01JM1X4XW756M1HG6XKMWM5423	1	2025-02-14 09:37:59.686021+00	2025-02-14 09:44:51.658+00	2025-02-14 09:44:51.658+00
variant_01JM1X4XTQY4YRH3N0CSS33T64	iitem_01JM1X4XVRMMGK6433BBVGQMCX	pvitem_01JM1X4XW7PESJKQTCCKQAAPT9	1	2025-02-14 09:37:59.686021+00	2025-02-14 09:44:51.658+00	2025-02-14 09:44:51.658+00
variant_01JM1X4XTQFVB7NPPG2JFA8VFW	iitem_01JM1X4XVRAF9DVT642KXH1HDK	pvitem_01JM1X4XW7DRSE48D8VM91R7HY	1	2025-02-14 09:37:59.686021+00	2025-02-14 09:44:51.658+00	2025-02-14 09:44:51.658+00
variant_01JM1X4XTQGZKC0FSR2PX8ZSXB	iitem_01JM1X4XVRK97A5BGPCS10AFJC	pvitem_01JM1X4XW73G6539F3HCGSFQR9	1	2025-02-14 09:37:59.686021+00	2025-02-14 09:44:51.658+00	2025-02-14 09:44:51.658+00
variant_01JM2DKW971QTV2THPTNZY2NCS	iitem_01JM2DKW9KN5NBJ00AR20GWDS2	pvitem_01JM2DKW9W56DF0CF7MK72EG2T	1	2025-02-14 14:25:46.811992+00	2025-02-14 14:30:35.826+00	2025-02-14 14:30:35.825+00
variant_01JM1XHT11068FC4SMKD3HRH44	iitem_01JM1XHT1FR4194QFR26T95ZVD	pvitem_01JM1XHT1WX043TP28Z8M2Q3VV	1	2025-02-14 09:45:01.753906+00	2025-02-14 09:54:54.967+00	2025-02-14 09:54:54.967+00
variant_01JM1XHT11A05YH281BGDA282F	iitem_01JM1XHT1FKP74NGA6QX01F65N	pvitem_01JM1XHT1WRJ98R1TTPKK1ST2R	1	2025-02-14 09:45:01.753906+00	2025-02-14 09:54:54.968+00	2025-02-14 09:54:54.967+00
variant_01JM1XHT11SXAW5R5AB2HSX3S4	iitem_01JM1XHT1FXQ65FQ1EX95JSZ0H	pvitem_01JM1XHT1WBNNW5XSV4NJ55NRV	1	2025-02-14 09:45:01.753906+00	2025-02-14 09:54:54.968+00	2025-02-14 09:54:54.967+00
variant_01JM1XHT11HRYSSBDHN2TQCMT9	iitem_01JM1XHT1FWFCCD5EZR4HKT1DP	pvitem_01JM1XHT1WJMH91ZQF54RGQDVG	1	2025-02-14 09:45:01.753906+00	2025-02-14 09:54:54.968+00	2025-02-14 09:54:54.967+00
variant_01JM1XHT11GVVZMEQDH211SDCJ	iitem_01JM1XHT1F20B5V23BRCJ9YR7K	pvitem_01JM1XHT1WY1A90BHWTV6DEQ1E	1	2025-02-14 09:45:01.753906+00	2025-02-14 09:54:54.968+00	2025-02-14 09:54:54.967+00
variant_01JM1Y66YKVKKQVCS964M4V6WT	iitem_01JM1Y66Z3CZXEE0NQEXKPA6RP	pvitem_01JM1Y66ZE39FBY4PY1MVAKFXQ	1	2025-02-14 09:56:10.349384+00	2025-02-14 10:02:01.72+00	2025-02-14 10:02:01.72+00
variant_01JM1Y66YKMMR0P5BTRW029705	iitem_01JM1Y66Z3GPT1PP3QB0KZ2YNX	pvitem_01JM1Y66ZEM72G1TNQVDCT147Q	1	2025-02-14 09:56:10.349384+00	2025-02-14 10:02:01.72+00	2025-02-14 10:02:01.72+00
variant_01JM1Y66YKGHRE5TPHAYKBHH1A	iitem_01JM1Y66Z39MJADGNM2G4PX5YG	pvitem_01JM1Y66ZEDR74JRE2SBCFY1E6	1	2025-02-14 09:56:10.349384+00	2025-02-14 10:02:01.72+00	2025-02-14 10:02:01.72+00
variant_01JM1Y66YK45WE0CFB0MQW8VPN	iitem_01JM1Y66Z4EZ92MYYYWE6DWPDJ	pvitem_01JM1Y66ZE5GZXBB9HMVYZB780	1	2025-02-14 09:56:10.349384+00	2025-02-14 10:02:01.72+00	2025-02-14 10:02:01.72+00
variant_01JM1Y66YKZPNQYKYYGW9TYJJ2	iitem_01JM1Y66Z4BKDFEHY85RJD9YDA	pvitem_01JM1Y66ZEJ5CQBYMEWPPYA21T	1	2025-02-14 09:56:10.349384+00	2025-02-14 10:02:01.72+00	2025-02-14 10:02:01.72+00
variant_01JM1YH984A0FAA3XHASS25RZD	iitem_01JM1YH98Q2G36XMBXD7J864R1	pvitem_01JM1YH99C8B5RF9NFGNVVE39Z	1	2025-02-14 10:02:13.163526+00	2025-02-14 10:03:56.956+00	2025-02-14 10:03:56.955+00
variant_01JM1YH98414QZVY82GVX028DQ	iitem_01JM1YH98QQ504TC6D9R1TG0SM	pvitem_01JM1YH99C0T7RYGTVW50S7YFB	1	2025-02-14 10:02:13.163526+00	2025-02-14 10:03:56.956+00	2025-02-14 10:03:56.955+00
variant_01JM1YH985DCQ83G2NHNCQ8AC6	iitem_01JM1YH98QY213QQHDJXFH1K6F	pvitem_01JM1YH99C3KXXMXAWHTAN4CS3	1	2025-02-14 10:02:13.163526+00	2025-02-14 10:03:56.957+00	2025-02-14 10:03:56.955+00
variant_01JM1YH9853PRBDB84TBSCAZS6	iitem_01JM1YH98QK2YKS81JWDX6DWB5	pvitem_01JM1YH99CG75ASNK5WGTHRFMM	1	2025-02-14 10:02:13.163526+00	2025-02-14 10:03:56.957+00	2025-02-14 10:03:56.955+00
variant_01JM1YH985BQN739QSS9YPQVX5	iitem_01JM1YH98QJ8CF2P0ZG0ND9RVY	pvitem_01JM1YH99CEG48G15699PFJ936	1	2025-02-14 10:02:13.163526+00	2025-02-14 10:03:56.957+00	2025-02-14 10:03:56.955+00
variant_01JM2C9Y2MS6M5HGZM119FAVAT	iitem_01JM2C9Y33JT0687ZPKGW2915X	pvitem_01JM2C9Y3EBV9AZTW0JND5PBZF	1	2025-02-14 14:02:52.398173+00	2025-02-14 14:15:56.168+00	2025-02-14 14:15:56.167+00
variant_01JM2C9Y2MSRJ4XZEP0P757DXV	iitem_01JM2C9Y334PTBNFA1P3YTAAKW	pvitem_01JM2C9Y3EQW8QAKQMVZV4KR6P	1	2025-02-14 14:02:52.398173+00	2025-02-14 14:15:56.168+00	2025-02-14 14:15:56.167+00
variant_01JM2C9Y2MS0MRE56F5QAMYF6E	iitem_01JM2C9Y336830JFM2KN1BK1XG	pvitem_01JM2C9Y3FKDYKVED5521T6DJM	1	2025-02-14 14:02:52.398173+00	2025-02-14 14:15:56.168+00	2025-02-14 14:15:56.167+00
variant_01JM2C9Y2M2Q1V3DM7ZPEJ36Y9	iitem_01JM2C9Y33WE4BXM8Z4M4HH2FV	pvitem_01JM2C9Y3FFRRAMH0J82A02J4V	1	2025-02-14 14:02:52.398173+00	2025-02-14 14:15:56.168+00	2025-02-14 14:15:56.167+00
variant_01JM2C9Y2MB9ZBXXK433Y7QCJM	iitem_01JM2C9Y33G8531PVG1EKFT046	pvitem_01JM2C9Y3F7KAS53S444RKW0RP	1	2025-02-14 14:02:52.398173+00	2025-02-14 14:15:56.168+00	2025-02-14 14:15:56.167+00
variant_01JM1YPFVQSF3TEGYNVZ2FJREZ	iitem_01JM1YPFW8E9S8R0YXF07534B9	pvitem_01JM1YPFWPBCH8C15SR4RAPDRY	1	2025-02-14 10:05:03.765164+00	2025-02-14 10:20:30.503+00	2025-02-14 10:20:30.503+00
variant_01JM1YPFVQP5E5QK8CKDA30948	iitem_01JM1YPFW8C3B84JKKHKVJYWG3	pvitem_01JM1YPFWP6W146X9QG0YZBQMA	1	2025-02-14 10:05:03.765164+00	2025-02-14 10:20:30.503+00	2025-02-14 10:20:30.503+00
variant_01JM1YPFVQXDEZKXQTNPFVMZS6	iitem_01JM1YPFW8BG75GFX5WKHKM3P0	pvitem_01JM1YPFWP3MKEZVDCMXSS689B	1	2025-02-14 10:05:03.765164+00	2025-02-14 10:20:30.503+00	2025-02-14 10:20:30.503+00
variant_01JM1YPFVQPQT4T2T2MMHC6C5W	iitem_01JM1YPFW8VEBQDYHQVSQX1KC8	pvitem_01JM1YPFWP3XQSEBKFMVT01X7V	1	2025-02-14 10:05:03.765164+00	2025-02-14 10:20:30.503+00	2025-02-14 10:20:30.503+00
variant_01JM1YPFVQYWAXCD0K0AZB33QG	iitem_01JM1YPFW8H1PSSAFA9YK4B3Q5	pvitem_01JM1YPFWP3T25ZS2RBDHDJWKK	1	2025-02-14 10:05:03.765164+00	2025-02-14 10:20:30.503+00	2025-02-14 10:20:30.503+00
variant_01JM2D2W2QCD75KAAM48R130RA	iitem_01JM2D2W355HCTV9AX2RDSC6XB	pvitem_01JM2D2W3FZTJ8A7WS8D1136GB	1	2025-02-14 14:16:29.55104+00	2025-02-14 14:25:36.779+00	2025-02-14 14:25:36.779+00
variant_01JM2D2W2RZT6C47TTA5QWMC0B	iitem_01JM2D2W359N2VVQCZ9ZRN1RP4	pvitem_01JM2D2W3FB2PGBECV2M7QQS1A	1	2025-02-14 14:16:29.55104+00	2025-02-14 14:25:36.779+00	2025-02-14 14:25:36.779+00
variant_01JM2D2W2R16MX5C90J1BZ7F1J	iitem_01JM2D2W35P3ZYECSBXZYR0GAJ	pvitem_01JM2D2W3FAMHHJG4JK3MA6ZEA	1	2025-02-14 14:16:29.55104+00	2025-02-14 14:25:36.779+00	2025-02-14 14:25:36.779+00
variant_01JM2D2W2RSXGB04NSARFHNR8J	iitem_01JM2D2W35FB8K029PZ8ZBZC7V	pvitem_01JM2D2W3FN9VC5D96DP0CYK36	1	2025-02-14 14:16:29.55104+00	2025-02-14 14:25:36.779+00	2025-02-14 14:25:36.779+00
variant_01JM2D2W2RF1VB5677E6XKYJR3	iitem_01JM2D2W35SV9BTVFJ942M5AQQ	pvitem_01JM2D2W3GJ5A0GXBYD032JRQW	1	2025-02-14 14:16:29.55104+00	2025-02-14 14:25:36.779+00	2025-02-14 14:25:36.779+00
variant_01JM1ZKBWG7QS167ZT8SNRFV42	iitem_01JM1ZKBX10EYJDQBQM9095RSG	pvitem_01JM1ZKBXB9DFV6JM7RYJTJ6NE	1	2025-02-14 10:20:49.961515+00	2025-02-14 10:26:16.449+00	2025-02-14 10:26:16.448+00
variant_01JM1ZKBWGWTQHX3H77A2M9FZ7	iitem_01JM1ZKBX159PKNK3DXWPMRXJQ	pvitem_01JM1ZKBXBP0QZKGWRM6B8CA1Y	1	2025-02-14 10:20:49.961515+00	2025-02-14 10:26:16.449+00	2025-02-14 10:26:16.448+00
variant_01JM1ZKBWGVT3JN20KDKTP5BFK	iitem_01JM1ZKBX12SJET483WQRZNCH1	pvitem_01JM1ZKBXBTYT7YDN9W3CE6SMZ	1	2025-02-14 10:20:49.961515+00	2025-02-14 10:26:16.45+00	2025-02-14 10:26:16.448+00
variant_01JM1ZKBWGEBCRRW1C2WZ19GF8	iitem_01JM1ZKBX1FKFNS1K4QDYAR6Q7	pvitem_01JM1ZKBXBW4KAJXV04GRR8VQZ	1	2025-02-14 10:20:49.961515+00	2025-02-14 10:26:16.45+00	2025-02-14 10:26:16.448+00
variant_01JM1ZKBWGN28JANK0VCCV25W8	iitem_01JM1ZKBX2387C4GCEKV9AS1YQ	pvitem_01JM1ZKBXB99P3NPCKTXF5TC9Q	1	2025-02-14 10:20:49.961515+00	2025-02-14 10:26:16.45+00	2025-02-14 10:26:16.448+00
variant_01JM1ZXS89NYGGMYT1WRCYWG1M	iitem_01JM1ZXS8SAADWE3SX71F80BRY	pvitem_01JM1ZXS95C2W4K1A5NF8EPZVD	1	2025-02-14 10:26:31.332837+00	2025-02-14 10:32:00.203+00	2025-02-14 10:32:00.202+00
variant_01JM1ZXS89TAA18784E12CNXDA	iitem_01JM1ZXS8SY9ZBERWW7Q18M8M9	pvitem_01JM1ZXS96VCJ2R9X19FYZ6V9F	1	2025-02-14 10:26:31.332837+00	2025-02-14 10:32:00.203+00	2025-02-14 10:32:00.202+00
variant_01JM1ZXS89YEVDWARBVT65J3KC	iitem_01JM1ZXS8S5AXSSAJJFFP5H0MY	pvitem_01JM1ZXS96KHYPRJ0AFW3ENFPR	1	2025-02-14 10:26:31.332837+00	2025-02-14 10:32:00.203+00	2025-02-14 10:32:00.202+00
variant_01JM1ZXS89D6JAY45D9H6YEFPG	iitem_01JM1ZXS8SW6WNVAT2NE0S331R	pvitem_01JM1ZXS96KFVZZEP0J1X8P4R5	1	2025-02-14 10:26:31.332837+00	2025-02-14 10:32:00.203+00	2025-02-14 10:32:00.202+00
variant_01JM1ZXS89650SYC57N3C9DHHM	iitem_01JM1ZXS8SH6KQZNW8F2Q5NA5W	pvitem_01JM1ZXS96VTKVNGCEZ1N2KWBS	1	2025-02-14 10:26:31.332837+00	2025-02-14 10:32:00.203+00	2025-02-14 10:32:00.202+00
variant_01JM20CSZZC3F3HNGACSK5ZZDA	iitem_01JM20CT0GZXCWX6KP0R9XW620	pvitem_01JM20CT0VY7SZXQPC8ZMYP0BB	1	2025-02-14 10:34:43.610928+00	2025-02-14 10:47:38.62+00	2025-02-14 10:47:38.618+00
variant_01JM20CSZZC2HYXBYDTKC47BM4	iitem_01JM20CT0G68F8SSPVST10P5TX	pvitem_01JM20CT0W4EWN6RHZ46WW8N4Y	1	2025-02-14 10:34:43.610928+00	2025-02-14 10:47:38.62+00	2025-02-14 10:47:38.618+00
variant_01JM20CSZZHC46F0ZSECDFWEZ0	iitem_01JM20CT0GT704HMMCSN5CT3FB	pvitem_01JM20CT0WBHPE1JVZ9YYRM3GS	1	2025-02-14 10:34:43.610928+00	2025-02-14 10:47:38.62+00	2025-02-14 10:47:38.618+00
variant_01JM20CSZZGFGWDT7KWBZ31VCF	iitem_01JM20CT0G8D6D14MDNK8WZ5HW	pvitem_01JM20CT0WZSTXYRV27SZJJAFM	1	2025-02-14 10:34:43.610928+00	2025-02-14 10:47:38.62+00	2025-02-14 10:47:38.618+00
variant_01JM20CSZZ7AP35T4ZZJ2K7SRP	iitem_01JM20CT0GCH07YCGZB95JH33A	pvitem_01JM20CT0WHB5V64BGR8JJDDJ1	1	2025-02-14 10:34:43.610928+00	2025-02-14 10:47:38.62+00	2025-02-14 10:47:38.618+00
variant_01JM214XJF47HSPWFG9JV8GWGD	iitem_01JM214XJY3NJMQQ115JSP91R9	pvitem_01JM214XK9N67N438AYKGSS21B	1	2025-02-14 10:47:53.704137+00	2025-02-14 10:48:29.884+00	2025-02-14 10:48:29.884+00
variant_01JM214XJF9C7WBFN2D3S0GQ37	iitem_01JM214XJYGDYB5YXFZDS57BES	pvitem_01JM214XK9AG9SHKTXR4G6N54X	1	2025-02-14 10:47:53.704137+00	2025-02-14 10:48:29.884+00	2025-02-14 10:48:29.884+00
variant_01JM214XJFTMSG53R69YR1HBBJ	iitem_01JM214XJYTDSDC0AT5N4K3WN5	pvitem_01JM214XK92VZK3DG4XZHXSKGE	1	2025-02-14 10:47:53.704137+00	2025-02-14 10:48:29.884+00	2025-02-14 10:48:29.884+00
variant_01JM214XJFMZ7YMH9MAF05AVPK	iitem_01JM214XJYS3C2SMHQA4S60STG	pvitem_01JM214XK9QFJ02DBQWRTFF76A	1	2025-02-14 10:47:53.704137+00	2025-02-14 10:48:29.884+00	2025-02-14 10:48:29.884+00
variant_01JM214XJF3BZDB5BQA0BA54VG	iitem_01JM214XJYKP07TF266ZZGECPX	pvitem_01JM214XK91ENZE2B1CK0VZBDF	1	2025-02-14 10:47:53.704137+00	2025-02-14 10:48:29.884+00	2025-02-14 10:48:29.884+00
variant_01JM216BSVGFZBBP5NPYA769QS	iitem_01JM216BTFYJVDX01FF49X4HS0	pvitem_01JM216BTS7CRGQMHGBR114BXP	1	2025-02-14 10:48:41.048479+00	2025-02-14 13:52:56.922+00	2025-02-14 13:52:56.921+00
variant_01JM216BSV96MQJBFQRQJHK1CN	iitem_01JM216BTFS0HM6N7MZ5AG1C8F	pvitem_01JM216BTTW6SRXDHWJMJPY8AG	1	2025-02-14 10:48:41.048479+00	2025-02-14 13:52:56.922+00	2025-02-14 13:52:56.921+00
variant_01JM216BSVGC0REJX7DN9EHS1H	iitem_01JM216BTFGF4268ERADXGSH5X	pvitem_01JM216BTTFA9WJTJ9HY2RSVVG	1	2025-02-14 10:48:41.048479+00	2025-02-14 13:52:56.922+00	2025-02-14 13:52:56.921+00
variant_01JM216BSV5TBZ324ZGN3S211G	iitem_01JM216BTF91MFZ19M0G46EFEK	pvitem_01JM216BTTVWV42QX4Y627RHYM	1	2025-02-14 10:48:41.048479+00	2025-02-14 13:52:56.922+00	2025-02-14 13:52:56.921+00
variant_01JM216BSV8VX7G86TQJV8BMK8	iitem_01JM216BTF7TEMBF9V1RCKWXAA	pvitem_01JM216BTT9AGM17K8G82HW52E	1	2025-02-14 10:48:41.048479+00	2025-02-14 13:52:56.922+00	2025-02-14 13:52:56.921+00
variant_01JM2BQZF6H12ZVV0E74KYHT7G	iitem_01JM2BQZFQY5PG55C923QB8D61	pvitem_01JM2BQZG27F86MB1MCMB7YDZQ	1	2025-02-14 13:53:04.001153+00	2025-02-14 13:54:44.389+00	2025-02-14 13:54:44.385+00
variant_01JM2BQZF61QEEJFQBR749C109	iitem_01JM2BQZFPZDJDCV7DEFTZ632M	pvitem_01JM2BQZG2MNCZE2B6CWHRJAZZ	1	2025-02-14 13:53:04.001153+00	2025-02-14 13:54:50.799+00	2025-02-14 13:54:50.798+00
variant_01JM2BQZF62K4BM0W964MM00KN	iitem_01JM2BQZFQPEYH6AF6CKDW6KAZ	pvitem_01JM2BQZG2JJXSV50YP7KP40MH	1	2025-02-14 13:53:04.001153+00	2025-02-14 13:54:50.799+00	2025-02-14 13:54:50.798+00
variant_01JM2BQZF6C291VX9TQTBMJWAF	iitem_01JM2BQZFQS2VP7WQVZYKYTTYS	pvitem_01JM2BQZG28S53PH1SE8E2A34H	1	2025-02-14 13:53:04.001153+00	2025-02-14 13:54:50.799+00	2025-02-14 13:54:50.798+00
variant_01JM2BQZF637WXD2W0KYY79C75	iitem_01JM2BQZFQK30DMNQMBX092CTH	pvitem_01JM2BQZG2RGH0X0JRK3AW0EK1	1	2025-02-14 13:53:04.001153+00	2025-02-14 13:54:50.8+00	2025-02-14 13:54:50.798+00
variant_01JM2DKW97768FBNM9MZQX54Z1	iitem_01JM2DKW9MBEG14Z6ZKJP8NCA6	pvitem_01JM2DKW9WDWRRDJ4CBPQS2VTG	1	2025-02-14 14:25:46.811992+00	2025-02-14 14:30:35.826+00	2025-02-14 14:30:35.825+00
variant_01JM2DKW98YK271PCVXJMF1KR4	iitem_01JM2DKW9MD9KWGFEBM3RJJCYP	pvitem_01JM2DKW9W93S2QPSWSEXJY47G	1	2025-02-14 14:25:46.811992+00	2025-02-14 14:30:35.826+00	2025-02-14 14:30:35.825+00
variant_01JM2DKW98BTB970Z1HWERHS53	iitem_01JM2DKW9MY1PSH38347ADANH7	pvitem_01JM2DKW9X6FF14ZMSKDWH94D6	1	2025-02-14 14:25:46.811992+00	2025-02-14 14:30:35.826+00	2025-02-14 14:30:35.825+00
variant_01JM2DKW97MW40WQMJNFE8SH58	iitem_01JM2DKW9KHWF8GKD0C5CD2NCY	pvitem_01JM2DKW9WR1Q7YN11KWQ34GV7	1	2025-02-14 14:25:46.811992+00	2025-02-14 14:30:35.826+00	2025-02-14 14:30:35.825+00
variant_01JM2DWYKE5W4F9GCHS7TT2E0K	iitem_01JM2DWYKV99SQ90SH4PG2Y308	pvitem_01JM2DWYM44ZP3W9S1PA8KXAMH	1	2025-02-14 14:30:44.10774+00	2025-02-14 14:33:33.7+00	2025-02-14 14:33:33.7+00
variant_01JM2DWYKEH2R0T1VEWF5BBG02	iitem_01JM2DWYKV8RETZNG0QR42JZFQ	pvitem_01JM2DWYM4HR24C0R6E2WBXDY8	1	2025-02-14 14:30:44.10774+00	2025-02-14 14:33:33.7+00	2025-02-14 14:33:33.7+00
variant_01JM2DWYKEBJYSHGY3RBZCZHF1	iitem_01JM2DWYKVE3S3DDV6C42YN1DC	pvitem_01JM2DWYM4HVT3GC0VR51H0HM9	1	2025-02-14 14:30:44.10774+00	2025-02-14 14:33:33.7+00	2025-02-14 14:33:33.7+00
variant_01JM2DWYKE0PGCT07XFQ88R40Z	iitem_01JM2DWYKVKEY68YN1P5WBA9ME	pvitem_01JM2DWYM5TVX4PCXX6BX7J8SR	1	2025-02-14 14:30:44.10774+00	2025-02-14 14:33:33.7+00	2025-02-14 14:33:33.7+00
variant_01JM2DWYKFQ444FG22NHQ7E02Q	iitem_01JM2DWYKV1YQ1T29HX1TE8MV9	pvitem_01JM2DWYM5XD4J6KFBRDARAT6C	1	2025-02-14 14:30:44.10774+00	2025-02-14 14:33:33.7+00	2025-02-14 14:33:33.7+00
variant_01JM2E2AWJK67P0V6687Y9XDWK	iitem_01JM2E2AWYMC3A8N4SD4AEVKNS	pvitem_01JM2E2AX835M12F0949B4MDVB	1	2025-02-14 14:33:40.519536+00	2025-02-14 14:43:26.742+00	2025-02-14 14:43:26.742+00
variant_01JM2E2AWJ4MKAEG44N751P1V4	iitem_01JM2E2AWYBR2NYQZ69P95TAD4	pvitem_01JM2E2AX84FNQS0S3JTMRZ6AJ	1	2025-02-14 14:33:40.519536+00	2025-02-14 14:43:26.742+00	2025-02-14 14:43:26.742+00
variant_01JM2E2AWK5GRK72NAP1CZMYZV	iitem_01JM2E2AWYQM855DTCVBVRG0R5	pvitem_01JM2E2AX8BBSNWZA2E6DFA8DB	1	2025-02-14 14:33:40.519536+00	2025-02-14 14:43:26.742+00	2025-02-14 14:43:26.742+00
variant_01JM2E2AWKFZ9ZSSPZ9782C4AJ	iitem_01JM2E2AWY75K2DHKVG9TENGSH	pvitem_01JM2E2AX8VAYKMJB1D0392M2G	1	2025-02-14 14:33:40.519536+00	2025-02-14 14:43:26.743+00	2025-02-14 14:43:26.742+00
variant_01JM2E2AWKZJ0GD6SE7J9T6Y01	iitem_01JM2E2AWYMG4X2T43JCED6P8J	pvitem_01JM2E2AX8WF9JBK90ZR7FXNX5	1	2025-02-14 14:33:40.519536+00	2025-02-14 14:43:26.743+00	2025-02-14 14:43:26.742+00
variant_01JM2EME8J7YV9ZSM3S87RE2F1	iitem_01JM2EME8ZP0N5KJJNBX5EXE87	pvitem_01JM2EME99ZXS1AGZV19MF8GDA	1	2025-02-14 14:43:33.800557+00	2025-02-14 15:36:51.576+00	2025-02-14 15:36:51.575+00
variant_01JM2EME8J4Z2T3QWBPMV2J05B	iitem_01JM2EME90DNF80Z97PC8A7JCN	pvitem_01JM2EME999FWSQNBM91VJ8KMY	1	2025-02-14 14:43:33.800557+00	2025-02-14 15:36:51.576+00	2025-02-14 15:36:51.575+00
variant_01JM2EME8J4YT0973E3MC37691	iitem_01JM2EME90RBF3EBBP581RSM57	pvitem_01JM2EME99RCNBS0T01J3DQEM4	1	2025-02-14 14:43:33.800557+00	2025-02-14 15:36:51.576+00	2025-02-14 15:36:51.575+00
variant_01JM2EME8JVG0NZC9HTGKA03M2	iitem_01JM2EME90F4RD3X1TV0RR0AYD	pvitem_01JM2EME99XVPM2G68PRGT39AB	1	2025-02-14 14:43:33.800557+00	2025-02-14 15:36:51.576+00	2025-02-14 15:36:51.575+00
variant_01JM2EME8J8DDQ5TBX8QJD33FA	iitem_01JM2EME906V1ST2ZJ3RXKT9WR	pvitem_01JM2EME99JYXMS1ZYH5SXM03N	1	2025-02-14 14:43:33.800557+00	2025-02-14 15:36:51.576+00	2025-02-14 15:36:51.575+00
variant_01JM2HQQ7GXSRWQQ32FJKGK0KK	iitem_01JM2HQQ8A75PFVHR3TZV8GS6M	pvitem_01JM2HQQ8QZ4WSE32YF351TQ2D	1	2025-02-14 15:37:47.031145+00	2025-02-14 15:39:13.455+00	2025-02-14 15:39:13.455+00
variant_01JM2HQQ7GJXZ171DBF284Q60W	iitem_01JM2HQQ8ASG1CYCFBS0KF986R	pvitem_01JM2HQQ8RK6T97AB58ZTA81SF	1	2025-02-14 15:37:47.031145+00	2025-02-14 15:39:13.455+00	2025-02-14 15:39:13.455+00
variant_01JM2HQQ7GWGG9VH5FY6YQQ3QR	iitem_01JM2HQQ8A5GFDXC2EGCTG0PMA	pvitem_01JM2HQQ8RDAGQMJH54HN6FD9F	1	2025-02-14 15:37:47.031145+00	2025-02-14 15:39:13.456+00	2025-02-14 15:39:13.455+00
variant_01JM2HQQ7GRSAFCJNWT0B6JQ81	iitem_01JM2HQQ8A12EGRYXRSRH7H5H6	pvitem_01JM2HQQ8R55RF0BHXYSBD4CGJ	1	2025-02-14 15:37:47.031145+00	2025-02-14 15:39:13.456+00	2025-02-14 15:39:13.455+00
variant_01JM2HQQ7GHZ1ZA6GKAC1Q8ZED	iitem_01JM2HQQ8BGVK94Z04NDH2JRZE	pvitem_01JM2HQQ8RXVT2QBJAZ2CKKKKD	1	2025-02-14 15:37:47.031145+00	2025-02-14 15:39:13.456+00	2025-02-14 15:39:13.455+00
variant_01JM2HTJ6V7G3AGXW9G8M8Z6J7	iitem_01JM2HTJ78E6G0E3CZYABGCRYN	pvitem_01JM2HTJ7JREC3QY3C1CV8KSST	1	2025-02-14 15:39:20.177301+00	2025-02-14 15:42:36.522+00	2025-02-14 15:42:36.522+00
variant_01JM2HTJ6V33M12JK6F611PAM7	iitem_01JM2HTJ78XPQ45E4VP2EG97ZR	pvitem_01JM2HTJ7J79BG2EJZTK1KDR72	1	2025-02-14 15:39:20.177301+00	2025-02-14 15:42:36.522+00	2025-02-14 15:42:36.522+00
variant_01JM2HTJ6V2V12P1XC3H0PB4DH	iitem_01JM2HTJ783AH3J3DKAJ9WKPZ3	pvitem_01JM2HTJ7JFQ1532YX0WV9PWSN	1	2025-02-14 15:39:20.177301+00	2025-02-14 15:42:36.522+00	2025-02-14 15:42:36.522+00
variant_01JM2HTJ6W79908PTH99SR3NSH	iitem_01JM2HTJ78A16Y7MG5XWY599ES	pvitem_01JM2HTJ7J3T20VQK9SD3M967D	1	2025-02-14 15:39:20.177301+00	2025-02-14 15:42:36.522+00	2025-02-14 15:42:36.522+00
variant_01JM2HTJ6WFMRW5HQFQQ64D5WD	iitem_01JM2HTJ78V4XK9YC0T4AJN3FK	pvitem_01JM2HTJ7J6ES58HW93JGTR779	1	2025-02-14 15:39:20.177301+00	2025-02-14 15:42:36.522+00	2025-02-14 15:42:36.522+00
variant_01JM2J0QEENMCCAYY13QY5W8GP	iitem_01JM2J0QEY0J27PCVGB0SKBF82	pvitem_01JM2J0QF82JEAYDA9G2ZTEEWF	1	2025-02-14 15:42:42.151457+00	2025-02-14 15:49:16.202+00	2025-02-14 15:49:16.202+00
variant_01JM2J0QEEAWYPCC2MSNWPPYS6	iitem_01JM2J0QEY9BWEWHMDJ5YY03NA	pvitem_01JM2J0QF8E4D1P9H9AN7XP1QC	1	2025-02-14 15:42:42.151457+00	2025-02-14 15:49:16.202+00	2025-02-14 15:49:16.202+00
variant_01JM2J0QEEH73GY3FCSJD39RGV	iitem_01JM2J0QEZJBXM5XW73N534NXH	pvitem_01JM2J0QF8RMX5XWEWE9A0SQTJ	1	2025-02-14 15:42:42.151457+00	2025-02-14 15:49:16.202+00	2025-02-14 15:49:16.202+00
variant_01JM2J0QEED1E9A2RT6VJC3P3J	iitem_01JM2J0QEZN78JCNEYNRJYGAF2	pvitem_01JM2J0QF823JXESRD012KEAGA	1	2025-02-14 15:42:42.151457+00	2025-02-14 15:49:16.202+00	2025-02-14 15:49:16.202+00
variant_01JM2J0QEER0962YW0Z7FAR8VE	iitem_01JM2J0QEZ95ZQYDF9N6597XRX	pvitem_01JM2J0QF8554J1B37TG79XBEJ	1	2025-02-14 15:42:42.151457+00	2025-02-14 15:49:16.202+00	2025-02-14 15:49:16.202+00
variant_01JM2JD003PJTFMXYF8PMW04V1	iitem_01JM2JD00JT3EDH22J1J21M41H	pvitem_01JM2JD00W3G1ZFZYGGHX5ZGK8	1	2025-02-14 15:49:24.124149+00	2025-02-14 15:52:43.016+00	2025-02-14 15:52:43.016+00
variant_01JM2JD0032G9NX9JVS5P9G7KG	iitem_01JM2JD00J7Q72RBD24MVWTJRG	pvitem_01JM2JD00X0T7NCT0SDJS01F53	1	2025-02-14 15:49:24.124149+00	2025-02-14 15:52:47.568+00	2025-02-14 15:52:47.567+00
variant_01JM2JD003RMCN6H3G57WB99B1	iitem_01JM2JD00J0H2F8ZBS0MSMZCBR	pvitem_01JM2JD00XGHXDBB38JWWRKRWP	1	2025-02-14 15:49:24.124149+00	2025-02-14 15:52:47.568+00	2025-02-14 15:52:47.567+00
variant_01JM2JD004FW0X9KYT2HFAR4B2	iitem_01JM2JD00JZFT95CPBASZ1ZNDX	pvitem_01JM2JD00XSWZV90W03P45ET2X	1	2025-02-14 15:49:24.124149+00	2025-02-14 15:52:47.568+00	2025-02-14 15:52:47.567+00
variant_01JM2JD004DHSD3R5XVVDQYAY4	iitem_01JM2JD00JN8GCCXDMVJ9DVXGB	pvitem_01JM2JD00X9F7DP76HH3Z4PZQ9	1	2025-02-14 15:49:24.124149+00	2025-02-14 15:52:47.568+00	2025-02-14 15:52:47.567+00
variant_01JM2JKYQNQR247Y18RVTE1GWR	iitem_01JM2JKYR1D280MHWBYP0T32QC	pvitem_01JM2JKYRC7HNHP99H9YXF4FMB	1	2025-02-14 15:53:12.203786+00	2025-02-14 16:01:40.499+00	2025-02-14 16:01:40.499+00
variant_01JM2JKYQNSXXS44RHCPNVDQS3	iitem_01JM2JKYR1FVSV71SVFPMW6X55	pvitem_01JM2JKYRCE4X61MXEYFBAKHA7	1	2025-02-14 15:53:12.203786+00	2025-02-14 16:01:40.499+00	2025-02-14 16:01:40.499+00
variant_01JM2JKYQNZMT91TK6EG17D5JH	iitem_01JM2JKYR18816SBP88YN0PK72	pvitem_01JM2JKYRCYB5JQ9JXV7V0BECN	1	2025-02-14 15:53:12.203786+00	2025-02-14 16:01:40.499+00	2025-02-14 16:01:40.499+00
variant_01JM2JKYQNYAFP7PK83XWSH3D3	iitem_01JM2JKYR148N93899EBGT3F19	pvitem_01JM2JKYRCZNXC1VT3M9XE5ER5	1	2025-02-14 15:53:12.203786+00	2025-02-14 16:01:40.499+00	2025-02-14 16:01:40.499+00
variant_01JM2JKYQNY1XXEMVAX6H0PPC6	iitem_01JM2JKYR14AQZEC7JWJ8PWS0T	pvitem_01JM2JKYRC6S1VC9GRZDZWJV0Y	1	2025-02-14 15:53:12.203786+00	2025-02-14 16:01:40.499+00	2025-02-14 16:01:40.499+00
variant_01JM2K3ZSC3JK012FDYS2GD146	iitem_01JM2K3ZSSDCHZR98SV5AP5TMB	pvitem_01JM2K3ZT49B1KBEDEF23B85M8	1	2025-02-14 16:01:57.572022+00	2025-02-14 16:01:57.572022+00	\N
variant_01JM2K3ZSDXRS6ED0N6TJAE31K	iitem_01JM2K3ZSSXYGDFSF4R8BESBP1	pvitem_01JM2K3ZT4WM924PSMM1EPJF1G	1	2025-02-14 16:01:57.572022+00	2025-02-14 16:01:57.572022+00	\N
variant_01JM2K3ZSD4MM311EXN487TMX6	iitem_01JM2K3ZSST54JVT6P1MZJM62J	pvitem_01JM2K3ZT4KN2F7WA8826PMPQC	1	2025-02-14 16:01:57.572022+00	2025-02-14 16:01:57.572022+00	\N
variant_01JM2K3ZSDF0SD3GRCA3ZJMFS2	iitem_01JM2K3ZSSX77D2VYT8W4GQPF4	pvitem_01JM2K3ZT5K4EPAWQD36Z3RPJ9	1	2025-02-14 16:01:57.572022+00	2025-02-14 16:01:57.572022+00	\N
variant_01JM2K3ZSD3B6MS40VCPVRDWAJ	iitem_01JM2K3ZSSAEVFYR6S412HV3B0	pvitem_01JM2K3ZT5PGM1DGYP89VJQYZN	1	2025-02-14 16:01:57.572022+00	2025-02-14 16:01:57.572022+00	\N
\.


--
-- Data for Name: product_variant_option; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variant_option (variant_id, option_value_id) FROM stdin;
variant_01JM18DSNACS3GXYYB39GFMKPX	optval_01JM18DSKRD544W38QG1B8EF51
variant_01JM18DSNACS3GXYYB39GFMKPX	optval_01JM18DSKRB75NFEY9JCA55Y8K
variant_01JM18DSNBYTFQ1NCE20H3ZSQ8	optval_01JM18DSKRD544W38QG1B8EF51
variant_01JM18DSNBYTFQ1NCE20H3ZSQ8	optval_01JM18DSKR5FXZ5FYR6QZNAW8V
variant_01JM18DSNBZ7305PJ1BB16B7NJ	optval_01JM18DSKR8RJHBNZKMFFZVH7A
variant_01JM18DSNBZ7305PJ1BB16B7NJ	optval_01JM18DSKRB75NFEY9JCA55Y8K
variant_01JM18DSNBKGQBK8MTNPBP4WGK	optval_01JM18DSKR8RJHBNZKMFFZVH7A
variant_01JM18DSNBKGQBK8MTNPBP4WGK	optval_01JM18DSKR5FXZ5FYR6QZNAW8V
variant_01JM18DSNBBW851G7XADR5Y11G	optval_01JM18DSKR3Y5957BTE8RK3D7C
variant_01JM18DSNBBW851G7XADR5Y11G	optval_01JM18DSKRB75NFEY9JCA55Y8K
variant_01JM18DSNBJ6MZ96S8DFKTCTJZ	optval_01JM18DSKR3Y5957BTE8RK3D7C
variant_01JM18DSNBJ6MZ96S8DFKTCTJZ	optval_01JM18DSKR5FXZ5FYR6QZNAW8V
variant_01JM18DSNB55W3XDMBK0Y8QWD6	optval_01JM18DSKRX5JJ8716R7R15H85
variant_01JM18DSNB55W3XDMBK0Y8QWD6	optval_01JM18DSKRB75NFEY9JCA55Y8K
variant_01JM18DSNBRM5FFHXBTZ8DYG8D	optval_01JM18DSKRX5JJ8716R7R15H85
variant_01JM18DSNBRM5FFHXBTZ8DYG8D	optval_01JM18DSKR5FXZ5FYR6QZNAW8V
variant_01JM18DSNBCP10KK5FM55NC1P6	optval_01JM18DSKS5C8KJFD7MGGSE30B
variant_01JM18DSNB6TMM157AD54G8JNK	optval_01JM18DSKS6R37K78AR1QDPP6E
variant_01JM18DSNBQEC5YPHMEF90YH6V	optval_01JM18DSKSDYC3DT1CR8G00NE8
variant_01JM18DSNC9CH6Y05WGBSF2P7A	optval_01JM18DSKSABVP7J3TGEQE4XE8
variant_01JM18DSNCWH0FSR51J3GMP2J5	optval_01JM18DSKTEPD5JP4YXZA5B251
variant_01JM18DSNC9YD7MY1RS24BRRAN	optval_01JM18DSKTTQW3ZT7SGEEBD830
variant_01JM18DSNCJWHT8XE7NW8GR0P3	optval_01JM18DSKT0EM2S4S7PP4YXAPA
variant_01JM18DSNC978BYBNCGC6MNCCJ	optval_01JM18DSKT4PDGHF49CDF2R6AC
variant_01JM18DSNCMPAPM2E7A096B2JY	optval_01JM18DSKVZ6W1WG9Z11BFGKMX
variant_01JM18DSNCW8Q9A9TFMFYNBX2C	optval_01JM18DSKV38Y57QGE1MTRZA6G
variant_01JM18DSNC0VTDG213TNW0YMKJ	optval_01JM18DSKV86PGVBBJJYYYYND8
variant_01JM18DSNCDA0YH5QGTSY5KKTY	optval_01JM18DSKVC9WH2SX84QFH35KW
variant_01JM1E0C0N5YP45XWKT9FEZMZ8	optval_01JM1E0BZJ1HKFSV5DFCGZQZHJ
variant_01JM1E0C0N5YP45XWKT9FEZMZ8	optval_01JM1E0BZJKAYX58KM6MXKRJJZ
variant_01JM1E0C0N5VRYBWD3WP9X5QHA	optval_01JM1E0BZJ1HKFSV5DFCGZQZHJ
variant_01JM1E0C0N5VRYBWD3WP9X5QHA	optval_01JM1E0BZJKJP46PBKYH7R5KZF
variant_01JM1E0C0NY8EENH3GJ708M5WP	optval_01JM1E0BZJ1HKFSV5DFCGZQZHJ
variant_01JM1E0C0NY8EENH3GJ708M5WP	optval_01JM1E0BZJBY823Z6CEVZGA6NX
variant_01JM1E0C0N8K92B4ZSE30JT615	optval_01JM1E0BZJ1HKFSV5DFCGZQZHJ
variant_01JM1E0C0N8K92B4ZSE30JT615	optval_01JM1E0BZJS8DAEGA2063NM8AH
variant_01JM1E0C0N5G5927E2G2VBRX63	optval_01JM1E0BZJN0873EW23WC8X0CG
variant_01JM1E0C0N5G5927E2G2VBRX63	optval_01JM1E0BZJKAYX58KM6MXKRJJZ
variant_01JM1E0C0NF88ZPW5JD3SCZ186	optval_01JM1E0BZJN0873EW23WC8X0CG
variant_01JM1E0C0NF88ZPW5JD3SCZ186	optval_01JM1E0BZJKJP46PBKYH7R5KZF
variant_01JM1E0C0P7G25GVZ4X3QT2GCJ	optval_01JM1E0BZJN0873EW23WC8X0CG
variant_01JM1E0C0P7G25GVZ4X3QT2GCJ	optval_01JM1E0BZJBY823Z6CEVZGA6NX
variant_01JM1E0C0PGGR2N4YVX50M38BJ	optval_01JM1E0BZJN0873EW23WC8X0CG
variant_01JM1E0C0PGGR2N4YVX50M38BJ	optval_01JM1E0BZJS8DAEGA2063NM8AH
variant_01JM1X4XTQQBG6VK83CSAY1GRR	optval_01JM1X4XSFXSA1EYG4APSRJ22M
variant_01JM1X4XTQ34CBRGMYFCNA4GMR	optval_01JM1X4XSFWPWDB29T0EE8VKTM
variant_01JM1X4XTQY4YRH3N0CSS33T64	optval_01JM1X4XSFDQF1V4HVGA0QGBVJ
variant_01JM1X4XTQFVB7NPPG2JFA8VFW	optval_01JM1X4XSFHS3P5Z9XZJSGAJS2
variant_01JM1X4XTQGZKC0FSR2PX8ZSXB	optval_01JM1X4XSF3ENEZNSF7NMSXYE0
variant_01JM1XHT11068FC4SMKD3HRH44	optval_01JM1XHT050Y00MZCZFVGCJ0N8
variant_01JM1XHT11A05YH281BGDA282F	optval_01JM1XHT05E7MJTV8SEAEMA2TH
variant_01JM1XHT11SXAW5R5AB2HSX3S4	optval_01JM1XHT05GW6AQGMN6BFYCFPM
variant_01JM1XHT11HRYSSBDHN2TQCMT9	optval_01JM1XHT05WSKD2XZSG2JPB991
variant_01JM1XHT11GVVZMEQDH211SDCJ	optval_01JM1XHT05XQZ3D9FFQERMHTCD
variant_01JM1Y66YKVKKQVCS964M4V6WT	optval_01JM1Y66XJ21RHB1TY4XQQ77G3
variant_01JM1Y66YKMMR0P5BTRW029705	optval_01JM1Y66XJ6XCVWEHNHQSAJ7T5
variant_01JM1Y66YKGHRE5TPHAYKBHH1A	optval_01JM1Y66XJ182QP0Z687MS2N9H
variant_01JM1Y66YK45WE0CFB0MQW8VPN	optval_01JM1Y66XJ15N35FKQVCQXYRP2
variant_01JM1Y66YKZPNQYKYYGW9TYJJ2	optval_01JM1Y66XJMJHAHRMV0PSEYPW5
variant_01JM1YH984A0FAA3XHASS25RZD	optval_01JM1YH974V10J31X3GA7BMG40
variant_01JM1YH98414QZVY82GVX028DQ	optval_01JM1YH974VR0BHEPG5RGY0S5F
variant_01JM1YH985DCQ83G2NHNCQ8AC6	optval_01JM1YH974B741BZFTZVW04PH3
variant_01JM1YH9853PRBDB84TBSCAZS6	optval_01JM1YH974B2J80T3NMF29C1ED
variant_01JM1YH985BQN739QSS9YPQVX5	optval_01JM1YH9742BMGK5V47M7EY8DX
variant_01JM1YPFVQSF3TEGYNVZ2FJREZ	optval_01JM1YPFTX51TTCCZS5Z9JZYN4
variant_01JM1YPFVQP5E5QK8CKDA30948	optval_01JM1YPFTXNB3DFAB56GB7T0ER
variant_01JM1YPFVQXDEZKXQTNPFVMZS6	optval_01JM1YPFTXA0VQ5V3MAMEQCN3Z
variant_01JM1YPFVQPQT4T2T2MMHC6C5W	optval_01JM1YPFTXA8VACFTVJ9BK0HPA
variant_01JM1YPFVQYWAXCD0K0AZB33QG	optval_01JM1YPFTXW5YQZXJCAQT635ZG
variant_01JM1ZKBWG7QS167ZT8SNRFV42	optval_01JM1ZKBVDHZYPTTSA4J7BM1JM
variant_01JM1ZKBWGWTQHX3H77A2M9FZ7	optval_01JM1ZKBVDM49MW10WQBWG5ABH
variant_01JM1ZKBWGVT3JN20KDKTP5BFK	optval_01JM1ZKBVETEM87YRCD7GYT2SB
variant_01JM1ZKBWGEBCRRW1C2WZ19GF8	optval_01JM1ZKBVEZKTCYDQQCNKT0ZQS
variant_01JM1ZKBWGN28JANK0VCCV25W8	optval_01JM1ZKBVECJGY0PX8100JDZNJ
variant_01JM1ZXS89NYGGMYT1WRCYWG1M	optval_01JM1ZXS7B6XYRRW15CNTF7NYA
variant_01JM1ZXS89TAA18784E12CNXDA	optval_01JM1ZXS7BM9EM1PQT456CTR9M
variant_01JM1ZXS89YEVDWARBVT65J3KC	optval_01JM1ZXS7BNFNXSY284MWKEPDJ
variant_01JM1ZXS89D6JAY45D9H6YEFPG	optval_01JM1ZXS7BEA4946NH8EV6M9W1
variant_01JM1ZXS89650SYC57N3C9DHHM	optval_01JM1ZXS7BPE8K2ZKC0YKDZWR1
variant_01JM20CSZZC3F3HNGACSK5ZZDA	optval_01JM20CSYVF3GFX07QXQBJ3T06
variant_01JM20CSZZC2HYXBYDTKC47BM4	optval_01JM20CSYVHHP8MHP6SH3HCGZ1
variant_01JM20CSZZHC46F0ZSECDFWEZ0	optval_01JM20CSYV0X670DDVXK5ZEPNJ
variant_01JM20CSZZGFGWDT7KWBZ31VCF	optval_01JM20CSYV2HZJW2027SEZ9PB4
variant_01JM20CSZZ7AP35T4ZZJ2K7SRP	optval_01JM20CSYVB7ZPV323ZSEXDSA9
variant_01JM214XJF47HSPWFG9JV8GWGD	optval_01JM214XH894MAK6FYK06Q0BKQ
variant_01JM214XJF9C7WBFN2D3S0GQ37	optval_01JM214XH82MR1N5D1N2WX9TNQ
variant_01JM214XJFTMSG53R69YR1HBBJ	optval_01JM214XH8EG0MD5S6Q1QTHV67
variant_01JM214XJFMZ7YMH9MAF05AVPK	optval_01JM214XH8RXNE3WJHSJRX2MJQ
variant_01JM214XJF3BZDB5BQA0BA54VG	optval_01JM214XH8KJ2TGM1KJBB7W8NK
variant_01JM216BSVGFZBBP5NPYA769QS	optval_01JM216BRX8AVRVM7WG2M1GDKE
variant_01JM216BSV96MQJBFQRQJHK1CN	optval_01JM216BRXRHR5E0QWRGANC2TK
variant_01JM216BSVGC0REJX7DN9EHS1H	optval_01JM216BRXEG405V8VMRN9Y7CT
variant_01JM216BSV5TBZ324ZGN3S211G	optval_01JM216BRXQPTSV61QEJS4BV78
variant_01JM216BSV8VX7G86TQJV8BMK8	optval_01JM216BRX1ATNH63CQ65Y29JW
variant_01JM2BQZF61QEEJFQBR749C109	optval_01JM2BQZE8K95SGNE57W137Y22
variant_01JM2BQZF62K4BM0W964MM00KN	optval_01JM2BQZE82KZ4YECTD650ZK6S
variant_01JM2BQZF6C291VX9TQTBMJWAF	optval_01JM2BQZE8K1JTTAQFXYK02GBX
variant_01JM2BQZF637WXD2W0KYY79C75	optval_01JM2BQZE8K52NWARCQNJGJG6B
variant_01JM2BQZF6H12ZVV0E74KYHT7G	optval_01JM2BQZE8RPBHSFM28YNYQ7EJ
variant_01JM2C9Y2MS6M5HGZM119FAVAT	optval_01JM2C9Y1R014CWWRB3S9AKB5D
variant_01JM2C9Y2MSRJ4XZEP0P757DXV	optval_01JM2C9Y1R6FQG7T2RPJ3D1CSZ
variant_01JM2C9Y2MS0MRE56F5QAMYF6E	optval_01JM2C9Y1RJPGNA2CV0S3CS06Y
variant_01JM2C9Y2M2Q1V3DM7ZPEJ36Y9	optval_01JM2C9Y1SMMZK39VHTW19840X
variant_01JM2C9Y2MB9ZBXXK433Y7QCJM	optval_01JM2C9Y1SX8R99RFY13HV1M88
variant_01JM2D2W2QCD75KAAM48R130RA	optval_01JM2D2W0M0GDPVP2SC3G47RPJ
variant_01JM2D2W2RZT6C47TTA5QWMC0B	optval_01JM2D2W0MX3D8YCHCFJ0MSJ6D
variant_01JM2D2W2R16MX5C90J1BZ7F1J	optval_01JM2D2W0MMW6J0R1S1WXJNQZR
variant_01JM2D2W2RSXGB04NSARFHNR8J	optval_01JM2D2W0MPE372BXJW964PD6H
variant_01JM2D2W2RF1VB5677E6XKYJR3	optval_01JM2D2W0MCNJX2M705EFSSXJC
variant_01JM2DKW97MW40WQMJNFE8SH58	optval_01JM2DKW75VG67505GT1HVZ8QV
variant_01JM2DKW971QTV2THPTNZY2NCS	optval_01JM2DKW75HH933T2DXNYHXPCZ
variant_01JM2DKW97768FBNM9MZQX54Z1	optval_01JM2DKW75MBSJZNR82KEMRXVZ
variant_01JM2DKW98YK271PCVXJMF1KR4	optval_01JM2DKW75ANFNV640CRBM5E8P
variant_01JM2DKW98BTB970Z1HWERHS53	optval_01JM2DKW75XP4A83NAZQQGRM29
variant_01JM2DWYKE5W4F9GCHS7TT2E0K	optval_01JM2DWYHGZEGMAY69VXXPVBZM
variant_01JM2DWYKEH2R0T1VEWF5BBG02	optval_01JM2DWYHG9TS83Y7BSZKBJQA7
variant_01JM2DWYKEBJYSHGY3RBZCZHF1	optval_01JM2DWYHGWNMPCZRMGN2H02C7
variant_01JM2DWYKE0PGCT07XFQ88R40Z	optval_01JM2DWYHGNHZXMT2XHZGQZ1DC
variant_01JM2DWYKFQ444FG22NHQ7E02Q	optval_01JM2DWYHGHPRA3XST99KXWD0X
variant_01JM2E2AWJK67P0V6687Y9XDWK	optval_01JM2E2ATKD6TY1JEBM05J4Q6T
variant_01JM2E2AWJ4MKAEG44N751P1V4	optval_01JM2E2ATK06KRFCRTEDC7YGZB
variant_01JM2E2AWK5GRK72NAP1CZMYZV	optval_01JM2E2ATMFRGY06SGFHB9MZ2T
variant_01JM2E2AWKFZ9ZSSPZ9782C4AJ	optval_01JM2E2ATM34CFGDSSAFN65EJW
variant_01JM2E2AWKZJ0GD6SE7J9T6Y01	optval_01JM2E2ATMWWQ67X6FE8RCTWRQ
variant_01JM2EME8J7YV9ZSM3S87RE2F1	optval_01JM2EME6J3106G8K5TNGT8KWF
variant_01JM2EME8J4Z2T3QWBPMV2J05B	optval_01JM2EME6JJQE2NKZP8QJTCC18
variant_01JM2EME8J4YT0973E3MC37691	optval_01JM2EME6JXN1AFN00CAZGJYWJ
variant_01JM2EME8JVG0NZC9HTGKA03M2	optval_01JM2EME6KB8ZEJSM4XKBMJJVG
variant_01JM2EME8J8DDQ5TBX8QJD33FA	optval_01JM2EME6KKE2XKQ74YRVV0E3A
variant_01JM2HQQ7GXSRWQQ32FJKGK0KK	optval_01JM2HQQ55XTZFE9KFWC0RFXX0
variant_01JM2HQQ7GJXZ171DBF284Q60W	optval_01JM2HQQ55V30HFK3WA2V9N3N9
variant_01JM2HQQ7GWGG9VH5FY6YQQ3QR	optval_01JM2HQQ55K6PZKMDGF3SPJTTB
variant_01JM2HQQ7GRSAFCJNWT0B6JQ81	optval_01JM2HQQ5569H1JW2JDHR3G2X5
variant_01JM2HQQ7GHZ1ZA6GKAC1Q8ZED	optval_01JM2HQQ55XW4ZVJ4C3V191J0Q
variant_01JM2HTJ6V7G3AGXW9G8M8Z6J7	optval_01JM2HTJ5BQSZWA5RMNV37EB6M
variant_01JM2HTJ6V33M12JK6F611PAM7	optval_01JM2HTJ5BHN3C36PE8P64AVZG
variant_01JM2HTJ6V2V12P1XC3H0PB4DH	optval_01JM2HTJ5CSM1SJKQ07ZC9N6TC
variant_01JM2HTJ6W79908PTH99SR3NSH	optval_01JM2HTJ5CB4HFN2KZKBYCCGZD
variant_01JM2HTJ6WFMRW5HQFQQ64D5WD	optval_01JM2HTJ5C677EWYM9DJEDYYQZ
variant_01JM2J0QEENMCCAYY13QY5W8GP	optval_01JM2J0QDAEK8XZFRVS3AK4ZAT
variant_01JM2J0QEEAWYPCC2MSNWPPYS6	optval_01JM2J0QDAKG8Q19D4HENK84DE
variant_01JM2J0QEEH73GY3FCSJD39RGV	optval_01JM2J0QDAAPMCHSVWGYHF6F92
variant_01JM2J0QEED1E9A2RT6VJC3P3J	optval_01JM2J0QDANBXGC9839AV713ZG
variant_01JM2J0QEER0962YW0Z7FAR8VE	optval_01JM2J0QDAHJ80WD3N0S0441W1
variant_01JM2JD003PJTFMXYF8PMW04V1	optval_01JM2JCZYVV3PZDRE1E4NAJCBX
variant_01JM2JD0032G9NX9JVS5P9G7KG	optval_01JM2JCZYVVH3YCNBWHN306GJ2
variant_01JM2JD003RMCN6H3G57WB99B1	optval_01JM2JCZYVN1CXR91Y0PN92YZ6
variant_01JM2JD004FW0X9KYT2HFAR4B2	optval_01JM2JCZYVV9XKZGJ1C9HJGBNQ
variant_01JM2JD004DHSD3R5XVVDQYAY4	optval_01JM2JCZYVEM15F452Q4MJF5ZR
variant_01JM2JKYQNQR247Y18RVTE1GWR	optval_01JM2JKYPMWMHW28WK1GV9ZB7V
variant_01JM2JKYQNSXXS44RHCPNVDQS3	optval_01JM2JKYPMH9D7X1DR1BCM1DMF
variant_01JM2JKYQNZMT91TK6EG17D5JH	optval_01JM2JKYPM96KXJP8GP8KQ3F6S
variant_01JM2JKYQNYAFP7PK83XWSH3D3	optval_01JM2JKYPMP1EZKH7QMJ44SNHZ
variant_01JM2JKYQNY1XXEMVAX6H0PPC6	optval_01JM2JKYPMHAPCCXQ29AWGC1K9
variant_01JM2K3ZSC3JK012FDYS2GD146	optval_01JM2K3ZR3HVF329S87KVF9BRS
variant_01JM2K3ZSDXRS6ED0N6TJAE31K	optval_01JM2K3ZR3BJW48ADCABRYMGZE
variant_01JM2K3ZSD4MM311EXN487TMX6	optval_01JM2K3ZR3PT9259ETR3XS62KF
variant_01JM2K3ZSDF0SD3GRCA3ZJMFS2	optval_01JM2K3ZR3HQ6QF8N7AJFYV5CE
variant_01JM2K3ZSD3B6MS40VCPVRDWAJ	optval_01JM2K3ZR3EGE48P5XTWDJGYCG
\.


--
-- Data for Name: product_variant_price_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variant_price_set (variant_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
variant_01JM18DSNACS3GXYYB39GFMKPX	pset_01JM18DSPMNN4781DJBK624AFC	pvps_01JM18DSQBKGCVHP7ERGG9NQNB	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNBYTFQ1NCE20H3ZSQ8	pset_01JM18DSPM0G8GD5X63F2QCPD6	pvps_01JM18DSQC7FY0J9SMEWJYTJ3H	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNBZ7305PJ1BB16B7NJ	pset_01JM18DSPNBX3QZ09BX64WN5WE	pvps_01JM18DSQCK022KZXF0QPNQQTZ	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNBKGQBK8MTNPBP4WGK	pset_01JM18DSPNHG5PK2GYX1KCVEFQ	pvps_01JM18DSQC8ZYGAG791P2F58R3	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNBBW851G7XADR5Y11G	pset_01JM18DSPNHZT2HCYXR0GHHCE7	pvps_01JM18DSQCZ9WATCY3MNA1JCC8	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNBJ6MZ96S8DFKTCTJZ	pset_01JM18DSPN60YD14JD9GAZDYKZ	pvps_01JM18DSQCC7BG7XYHR9XEH9SQ	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNB55W3XDMBK0Y8QWD6	pset_01JM18DSPNDVKAWR2NN6VV9DN9	pvps_01JM18DSQCZ37R43D1H9B2MQE5	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNBRM5FFHXBTZ8DYG8D	pset_01JM18DSPNVRYZKSR06MYMN0JB	pvps_01JM18DSQCRJEMMG0W1FYA9PHQ	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNBCP10KK5FM55NC1P6	pset_01JM18DSPPNAXZRZBRPF5E6459	pvps_01JM18DSQCSH4ZFJ1X2C4D421H	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNB6TMM157AD54G8JNK	pset_01JM18DSPPS0FTRFWPDMXY6F42	pvps_01JM18DSQD1S5ZY1557X6134EK	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNBQEC5YPHMEF90YH6V	pset_01JM18DSPPH222H6GV7T82E6H5	pvps_01JM18DSQDYT87CG9JZ87JM1Y7	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNC9CH6Y05WGBSF2P7A	pset_01JM18DSPPEY3PDR9C9HZ1KNNT	pvps_01JM18DSQDM33Z70QWW2ZF7XJA	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNCWH0FSR51J3GMP2J5	pset_01JM18DSPP6JY23PJBWHTEJ2XY	pvps_01JM18DSQDFHZ3MSCVJW6441T4	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNC9YD7MY1RS24BRRAN	pset_01JM18DSPP974MD6H7JZ7T2VGN	pvps_01JM18DSQDXB0A3V28WS596Q4N	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNCJWHT8XE7NW8GR0P3	pset_01JM18DSPPHYE768BJMY4SR8EK	pvps_01JM18DSQDQJVT7Z6T2DG06XN6	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNC978BYBNCGC6MNCCJ	pset_01JM18DSPP6X3FBRJQYX2YFC5P	pvps_01JM18DSQDA6V26652WQSHQ7RV	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNCMPAPM2E7A096B2JY	pset_01JM18DSPQ5YW3EDFKDZMKG4NN	pvps_01JM18DSQDKJWZ0FSWWT4DNM9K	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNCW8Q9A9TFMFYNBX2C	pset_01JM18DSPQZ05H6WHGY1XFKMC7	pvps_01JM18DSQDZ150K0S0M35Y1Q6Q	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNC0VTDG213TNW0YMKJ	pset_01JM18DSPQS5F2RKXKRK60NP67	pvps_01JM18DSQDP1K3N8DKCBAXQ615	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM18DSNCDA0YH5QGTSY5KKTY	pset_01JM18DSPQ1NF2T24SYCRQBWQC	pvps_01JM18DSQDAF3ZBEXNAVQ2GPBV	2025-02-14 03:35:50.250382+00	2025-02-14 03:35:50.250382+00	\N
variant_01JM1E0C0N5YP45XWKT9FEZMZ8	pset_01JM1E0C29PGJ7E8CT5FF7AGV7	pvps_01JM1E0C2WQFQ7A2SCQ6ZM6VT0	2025-02-14 05:13:21.755949+00	2025-02-14 05:14:37.662+00	2025-02-14 05:14:37.662+00
variant_01JM1E0C0N5VRYBWD3WP9X5QHA	pset_01JM1E0C29TN72WG7G6FW4GFY8	pvps_01JM1E0C2W2NR4063NVV5CGXVA	2025-02-14 05:13:21.755949+00	2025-02-14 05:14:37.662+00	2025-02-14 05:14:37.662+00
variant_01JM1E0C0NY8EENH3GJ708M5WP	pset_01JM1E0C29S4YNT1EH2NC77Q9P	pvps_01JM1E0C2WE0Z3Y8HKMW5FN5Y9	2025-02-14 05:13:21.755949+00	2025-02-14 05:14:37.662+00	2025-02-14 05:14:37.662+00
variant_01JM1E0C0N8K92B4ZSE30JT615	pset_01JM1E0C294GGS646TQNVZN13B	pvps_01JM1E0C2WN4RBTKV2JCZE7T6S	2025-02-14 05:13:21.755949+00	2025-02-14 05:14:37.662+00	2025-02-14 05:14:37.662+00
variant_01JM1E0C0N5G5927E2G2VBRX63	pset_01JM1E0C29BY6K8WZH0MWP5V9S	pvps_01JM1E0C2WRTM6YS0WCNPNZNB0	2025-02-14 05:13:21.755949+00	2025-02-14 05:14:37.662+00	2025-02-14 05:14:37.662+00
variant_01JM1E0C0NF88ZPW5JD3SCZ186	pset_01JM1E0C29GF7P000K459KQBW2	pvps_01JM1E0C2WNYHYE2GAX2NE5HG0	2025-02-14 05:13:21.755949+00	2025-02-14 05:14:37.662+00	2025-02-14 05:14:37.662+00
variant_01JM1E0C0P7G25GVZ4X3QT2GCJ	pset_01JM1E0C29C2ECWBHNAKAGZCK9	pvps_01JM1E0C2WECHMMNT4HF1XNWT0	2025-02-14 05:13:21.755949+00	2025-02-14 05:14:37.662+00	2025-02-14 05:14:37.662+00
variant_01JM1E0C0PGGR2N4YVX50M38BJ	pset_01JM1E0C2A5Z95B4DE7R2EC0NS	pvps_01JM1E0C2WA5BJB9RF3MFRWE4G	2025-02-14 05:13:21.755949+00	2025-02-14 05:14:37.662+00	2025-02-14 05:14:37.662+00
variant_01JM1X4XTQQBG6VK83CSAY1GRR	pset_01JM1X4XWFJ6SWFEC3XF038VXB	pvps_01JM1X4XWYKMXFPYXZET4F4X25	2025-02-14 09:37:59.709439+00	2025-02-14 09:44:51.669+00	2025-02-14 09:44:51.669+00
variant_01JM1X4XTQ34CBRGMYFCNA4GMR	pset_01JM1X4XWFXJGW9VJE297N59D6	pvps_01JM1X4XWYX3BNE2ERPFC0FPMS	2025-02-14 09:37:59.709439+00	2025-02-14 09:44:51.669+00	2025-02-14 09:44:51.669+00
variant_01JM1X4XTQY4YRH3N0CSS33T64	pset_01JM1X4XWFCCA9DPBV7C1BJDYE	pvps_01JM1X4XWYN2VQRN92ZDMEGMSH	2025-02-14 09:37:59.709439+00	2025-02-14 09:44:51.669+00	2025-02-14 09:44:51.669+00
variant_01JM1X4XTQFVB7NPPG2JFA8VFW	pset_01JM1X4XWF82RR84G212KDA56B	pvps_01JM1X4XWYG8Q13TM73WFYHH0W	2025-02-14 09:37:59.709439+00	2025-02-14 09:44:51.669+00	2025-02-14 09:44:51.669+00
variant_01JM1X4XTQGZKC0FSR2PX8ZSXB	pset_01JM1X4XWF1E3PE0WJ951P5PPY	pvps_01JM1X4XWYR561EXG1QF40TY0Q	2025-02-14 09:37:59.709439+00	2025-02-14 09:44:51.669+00	2025-02-14 09:44:51.669+00
variant_01JM1XHT11068FC4SMKD3HRH44	pset_01JM1XHT23Z9QNFQGC9RTXZAZJ	pvps_01JM1XHT2F7TFW8CJG2JMCTW6W	2025-02-14 09:45:01.774376+00	2025-02-14 09:54:54.991+00	2025-02-14 09:54:54.991+00
variant_01JM1XHT11A05YH281BGDA282F	pset_01JM1XHT230N2TMJVCF5E20Z6S	pvps_01JM1XHT2F2S8HKRA0TTJ59M9E	2025-02-14 09:45:01.774376+00	2025-02-14 09:54:54.991+00	2025-02-14 09:54:54.991+00
variant_01JM1XHT11SXAW5R5AB2HSX3S4	pset_01JM1XHT2334FM2HPPBX2PMT40	pvps_01JM1XHT2F0XHC201QY8D0WY6R	2025-02-14 09:45:01.774376+00	2025-02-14 09:54:54.991+00	2025-02-14 09:54:54.991+00
variant_01JM1XHT11HRYSSBDHN2TQCMT9	pset_01JM1XHT23V6CHMTNKAQMVESAK	pvps_01JM1XHT2F9EJ2J6YPR5Y3SA14	2025-02-14 09:45:01.774376+00	2025-02-14 09:54:54.991+00	2025-02-14 09:54:54.991+00
variant_01JM1XHT11GVVZMEQDH211SDCJ	pset_01JM1XHT23KYB7XXDVS8DHWVJQ	pvps_01JM1XHT2FBDEK2TKPV880FK7H	2025-02-14 09:45:01.774376+00	2025-02-14 09:54:54.991+00	2025-02-14 09:54:54.991+00
variant_01JM1Y66YKVKKQVCS964M4V6WT	pset_01JM1Y66ZPKMGGVQWM75M4TTMW	pvps_01JM1Y6707T8KXBR48W25YTB6F	2025-02-14 09:56:10.374335+00	2025-02-14 10:02:01.732+00	2025-02-14 10:02:01.732+00
variant_01JM1Y66YKMMR0P5BTRW029705	pset_01JM1Y66ZP4E2NN8H5RMG40T2P	pvps_01JM1Y67079P6F15X5XH54STVC	2025-02-14 09:56:10.374335+00	2025-02-14 10:02:01.732+00	2025-02-14 10:02:01.732+00
variant_01JM1Y66YKGHRE5TPHAYKBHH1A	pset_01JM1Y66ZP3FCM3NW145J66XBZ	pvps_01JM1Y6707KGDV86YH20TJZA33	2025-02-14 09:56:10.374335+00	2025-02-14 10:02:01.732+00	2025-02-14 10:02:01.732+00
variant_01JM1Y66YK45WE0CFB0MQW8VPN	pset_01JM1Y66ZPSA3X8VP5N889ERZF	pvps_01JM1Y67078NB90M7PBY49EB18	2025-02-14 09:56:10.374335+00	2025-02-14 10:02:01.732+00	2025-02-14 10:02:01.732+00
variant_01JM1Y66YKZPNQYKYYGW9TYJJ2	pset_01JM1Y66ZP45F1AMRR4W3QEJ6C	pvps_01JM1Y67077FZXQEWC7X3X49YA	2025-02-14 09:56:10.374335+00	2025-02-14 10:02:01.732+00	2025-02-14 10:02:01.732+00
variant_01JM1YH984A0FAA3XHASS25RZD	pset_01JM1YH99MYXWVD92892YJA8BY	pvps_01JM1YH9A5AZ4VCGBNWT18SPGY	2025-02-14 10:02:13.18849+00	2025-02-14 10:03:56.969+00	2025-02-14 10:03:56.969+00
variant_01JM1YH98414QZVY82GVX028DQ	pset_01JM1YH99MT1S24WDR0J3Q0HFS	pvps_01JM1YH9A5TQVB8WVS32ENX4M0	2025-02-14 10:02:13.18849+00	2025-02-14 10:03:56.969+00	2025-02-14 10:03:56.969+00
variant_01JM1YH985DCQ83G2NHNCQ8AC6	pset_01JM1YH99MSJ4TNZ0A45JJ1ZP3	pvps_01JM1YH9A5MM5KAQDDFMJERS0D	2025-02-14 10:02:13.18849+00	2025-02-14 10:03:56.969+00	2025-02-14 10:03:56.969+00
variant_01JM1YH9853PRBDB84TBSCAZS6	pset_01JM1YH99M5VEFB0FKDMXCZX50	pvps_01JM1YH9A5YBX892H2Z9QKMM90	2025-02-14 10:02:13.18849+00	2025-02-14 10:03:56.97+00	2025-02-14 10:03:56.969+00
variant_01JM1YH985BQN739QSS9YPQVX5	pset_01JM1YH99MK3MRPP3FNAS5APW7	pvps_01JM1YH9A51QBXQPJX4VWP5Q4R	2025-02-14 10:02:13.18849+00	2025-02-14 10:03:56.97+00	2025-02-14 10:03:56.969+00
variant_01JM2C9Y2MS6M5HGZM119FAVAT	pset_01JM2C9Y40NVGNB52FGAED0DR2	pvps_01JM2C9Y4DASVTG76KQXFHJZMY	2025-02-14 14:02:52.42813+00	2025-02-14 14:15:56.189+00	2025-02-14 14:15:56.188+00
variant_01JM1YPFVQSF3TEGYNVZ2FJREZ	pset_01JM1YPFWX25W9MV145V5CWQ35	pvps_01JM1YPFXBMMSXETTMSSFSA5H5	2025-02-14 10:05:03.786298+00	2025-02-14 10:20:30.515+00	2025-02-14 10:20:30.515+00
variant_01JM1YPFVQP5E5QK8CKDA30948	pset_01JM1YPFWXAYTP03TNSQMCFXG1	pvps_01JM1YPFXB6WWCW2Y24MNA70EG	2025-02-14 10:05:03.786298+00	2025-02-14 10:20:30.515+00	2025-02-14 10:20:30.515+00
variant_01JM1YPFVQXDEZKXQTNPFVMZS6	pset_01JM1YPFWXV3GVMJHH6XBMKKQC	pvps_01JM1YPFXBBXQ58B7932QBZYH2	2025-02-14 10:05:03.786298+00	2025-02-14 10:20:30.515+00	2025-02-14 10:20:30.515+00
variant_01JM1YPFVQPQT4T2T2MMHC6C5W	pset_01JM1YPFWXHZ699VS9RA49D9GQ	pvps_01JM1YPFXBCAHV0BERZWG61VKP	2025-02-14 10:05:03.786298+00	2025-02-14 10:20:30.515+00	2025-02-14 10:20:30.515+00
variant_01JM1YPFVQYWAXCD0K0AZB33QG	pset_01JM1YPFWXBQ8C802DKCF8M6RZ	pvps_01JM1YPFXB55R0JJG0VHKNZ6R0	2025-02-14 10:05:03.786298+00	2025-02-14 10:20:30.515+00	2025-02-14 10:20:30.515+00
variant_01JM2C9Y2MSRJ4XZEP0P757DXV	pset_01JM2C9Y40BZEZSE0M25PFZR83	pvps_01JM2C9Y4DC2WWSA60M8016KGD	2025-02-14 14:02:52.42813+00	2025-02-14 14:15:56.189+00	2025-02-14 14:15:56.188+00
variant_01JM2C9Y2MS0MRE56F5QAMYF6E	pset_01JM2C9Y40YPCZJPM6VMR889AS	pvps_01JM2C9Y4DTBQ1CBN02HTATGF9	2025-02-14 14:02:52.42813+00	2025-02-14 14:15:56.189+00	2025-02-14 14:15:56.188+00
variant_01JM2C9Y2M2Q1V3DM7ZPEJ36Y9	pset_01JM2C9Y4065D8YMNFRS7D4V9H	pvps_01JM2C9Y4DXC3C71J4NV4Y9GX1	2025-02-14 14:02:52.42813+00	2025-02-14 14:15:56.189+00	2025-02-14 14:15:56.188+00
variant_01JM2C9Y2MB9ZBXXK433Y7QCJM	pset_01JM2C9Y40S2JG2P484ZG74R84	pvps_01JM2C9Y4DW77CF7XH2VC7H4K8	2025-02-14 14:02:52.42813+00	2025-02-14 14:15:56.189+00	2025-02-14 14:15:56.188+00
variant_01JM2D2W2QCD75KAAM48R130RA	pset_01JM2D2W3PJ9T4WVY10J762T9E	pvps_01JM2D2W40Q9252WSFW6DQM02E	2025-02-14 14:16:29.56765+00	2025-02-14 14:25:36.795+00	2025-02-14 14:25:36.794+00
variant_01JM1ZKBWG7QS167ZT8SNRFV42	pset_01JM1ZKBXJREJ0BXPN0CM0XES5	pvps_01JM1ZKBY18T082J99V15E8XN2	2025-02-14 10:20:49.98368+00	2025-02-14 10:26:16.464+00	2025-02-14 10:26:16.464+00
variant_01JM1ZKBWGWTQHX3H77A2M9FZ7	pset_01JM1ZKBXJGCANECFATGGB6CDZ	pvps_01JM1ZKBY23YMV6XWPA9VP4J0F	2025-02-14 10:20:49.98368+00	2025-02-14 10:26:16.464+00	2025-02-14 10:26:16.464+00
variant_01JM1ZKBWGVT3JN20KDKTP5BFK	pset_01JM1ZKBXJFRF2WAXEW9XSWE7S	pvps_01JM1ZKBY21F72WH9H1WR2EZSQ	2025-02-14 10:20:49.98368+00	2025-02-14 10:26:16.464+00	2025-02-14 10:26:16.464+00
variant_01JM1ZKBWGEBCRRW1C2WZ19GF8	pset_01JM1ZKBXK7HP6M133AWRGE67T	pvps_01JM1ZKBY23X1CEJBRQRP9TCXM	2025-02-14 10:20:49.98368+00	2025-02-14 10:26:16.464+00	2025-02-14 10:26:16.464+00
variant_01JM1ZKBWGN28JANK0VCCV25W8	pset_01JM1ZKBXK1KKB1FCBSJSWZNEJ	pvps_01JM1ZKBY2J1MTWS8BFFDMC160	2025-02-14 10:20:49.98368+00	2025-02-14 10:26:16.464+00	2025-02-14 10:26:16.464+00
variant_01JM2D2W2RZT6C47TTA5QWMC0B	pset_01JM2D2W3PHV8Z5CA7PZDP9RXV	pvps_01JM2D2W409T2ZWTAYXGR02WBY	2025-02-14 14:16:29.56765+00	2025-02-14 14:25:36.795+00	2025-02-14 14:25:36.794+00
variant_01JM2D2W2R16MX5C90J1BZ7F1J	pset_01JM2D2W3PDKS0CYE90JTW2305	pvps_01JM2D2W40NZF96R2CR5955EGP	2025-02-14 14:16:29.56765+00	2025-02-14 14:25:36.795+00	2025-02-14 14:25:36.794+00
variant_01JM2D2W2RSXGB04NSARFHNR8J	pset_01JM2D2W3PJKNN9DJ7HBNKYQDN	pvps_01JM2D2W40X5NK9BY0ZPK5PMAR	2025-02-14 14:16:29.56765+00	2025-02-14 14:25:36.795+00	2025-02-14 14:25:36.794+00
variant_01JM2D2W2RF1VB5677E6XKYJR3	pset_01JM2D2W3PR4ZJTT8VSQ5GJG7X	pvps_01JM2D2W4035XB85F0Q8JK6SMX	2025-02-14 14:16:29.56765+00	2025-02-14 14:25:36.795+00	2025-02-14 14:25:36.794+00
variant_01JM2DKW97MW40WQMJNFE8SH58	pset_01JM2DKWA1D9PTQYJYW9V40SMD	pvps_01JM2DKWACW18VERRPDP4EK3Y8	2025-02-14 14:25:46.827288+00	2025-02-14 14:30:35.842+00	2025-02-14 14:30:35.842+00
variant_01JM1ZXS89NYGGMYT1WRCYWG1M	pset_01JM1ZXS9EBY1SEY1GMV2VBZ0Z	pvps_01JM1ZXS9TB2X63RR826EV58WD	2025-02-14 10:26:31.353182+00	2025-02-14 10:32:00.236+00	2025-02-14 10:32:00.235+00
variant_01JM1ZXS89TAA18784E12CNXDA	pset_01JM1ZXS9EW2YT1JMHPDXTTB30	pvps_01JM1ZXS9TKZP7QP2TPK3ZSRA7	2025-02-14 10:26:31.353182+00	2025-02-14 10:32:00.236+00	2025-02-14 10:32:00.235+00
variant_01JM1ZXS89YEVDWARBVT65J3KC	pset_01JM1ZXS9EH7F2TGGX3F3B4ET4	pvps_01JM1ZXS9T8MXZW476XA94MD9Y	2025-02-14 10:26:31.353182+00	2025-02-14 10:32:00.236+00	2025-02-14 10:32:00.235+00
variant_01JM1ZXS89D6JAY45D9H6YEFPG	pset_01JM1ZXS9E9KN9A9CCXJEQSZTC	pvps_01JM1ZXS9THP6NQGGYFWY2M1PX	2025-02-14 10:26:31.353182+00	2025-02-14 10:32:00.236+00	2025-02-14 10:32:00.235+00
variant_01JM1ZXS89650SYC57N3C9DHHM	pset_01JM1ZXS9ERZZ4QTW5WTRE1XMA	pvps_01JM1ZXS9T5ZKA94E4JEMTJYH2	2025-02-14 10:26:31.353182+00	2025-02-14 10:32:00.236+00	2025-02-14 10:32:00.235+00
variant_01JM2DKW971QTV2THPTNZY2NCS	pset_01JM2DKWA1P20Z6H9J9NW9A65R	pvps_01JM2DKWAC206GPCHV9M80V1HA	2025-02-14 14:25:46.827288+00	2025-02-14 14:30:35.842+00	2025-02-14 14:30:35.842+00
variant_01JM2DKW97768FBNM9MZQX54Z1	pset_01JM2DKWA1F4S5DW99V6R8M5QF	pvps_01JM2DKWACYSV4R3RA6JF6QTKP	2025-02-14 14:25:46.827288+00	2025-02-14 14:30:35.842+00	2025-02-14 14:30:35.842+00
variant_01JM2DKW98YK271PCVXJMF1KR4	pset_01JM2DKWA21M4PWYQ560ZC9JZD	pvps_01JM2DKWACFJ0NCEBZ4SNEBBVT	2025-02-14 14:25:46.827288+00	2025-02-14 14:30:35.842+00	2025-02-14 14:30:35.842+00
variant_01JM2DKW98BTB970Z1HWERHS53	pset_01JM2DKWA233M1C1G1KXCX6FQH	pvps_01JM2DKWAC3DAN36B5EKVR2BZR	2025-02-14 14:25:46.827288+00	2025-02-14 14:30:35.842+00	2025-02-14 14:30:35.842+00
variant_01JM2DWYKE5W4F9GCHS7TT2E0K	pset_01JM2DWYMAMJ5XSSG95T9V6Z13	pvps_01JM2DWYMNEF12ASAWFN9VNM1Q	2025-02-14 14:30:44.123881+00	2025-02-14 14:33:33.711+00	2025-02-14 14:33:33.711+00
variant_01JM20CSZZC3F3HNGACSK5ZZDA	pset_01JM20CT161RZQ0985N8PNDQE4	pvps_01JM20CT1PAAEV73ZMJWPTH8DK	2025-02-14 10:34:43.637408+00	2025-02-14 10:47:38.643+00	2025-02-14 10:47:38.643+00
variant_01JM20CSZZC2HYXBYDTKC47BM4	pset_01JM20CT161XC8G1S41CBSM1XQ	pvps_01JM20CT1P978Y6GSQB17GZZX3	2025-02-14 10:34:43.637408+00	2025-02-14 10:47:38.644+00	2025-02-14 10:47:38.643+00
variant_01JM20CSZZHC46F0ZSECDFWEZ0	pset_01JM20CT16BSJTFXYF7HER4TMQ	pvps_01JM20CT1PFJBYNF201VPJXVDY	2025-02-14 10:34:43.637408+00	2025-02-14 10:47:38.644+00	2025-02-14 10:47:38.643+00
variant_01JM20CSZZGFGWDT7KWBZ31VCF	pset_01JM20CT17A9SCDD1GPF4M3K65	pvps_01JM20CT1PYKV72GV8ETVW0ZD1	2025-02-14 10:34:43.637408+00	2025-02-14 10:47:38.644+00	2025-02-14 10:47:38.643+00
variant_01JM20CSZZ7AP35T4ZZJ2K7SRP	pset_01JM20CT17P1FFVAGTEAGEXMG2	pvps_01JM20CT1PBH4BF5M2WQ0D56BR	2025-02-14 10:34:43.637408+00	2025-02-14 10:47:38.644+00	2025-02-14 10:47:38.643+00
variant_01JM214XJF47HSPWFG9JV8GWGD	pset_01JM214XKJVVR3WVX53E5SBN0P	pvps_01JM214XKZDCAP1HHYYB4F19DS	2025-02-14 10:47:53.726315+00	2025-02-14 10:48:29.894+00	2025-02-14 10:48:29.894+00
variant_01JM214XJF9C7WBFN2D3S0GQ37	pset_01JM214XKJB6PF6H4CMGT0HBHP	pvps_01JM214XKZEWGW2QKHBREW71EW	2025-02-14 10:47:53.726315+00	2025-02-14 10:48:29.894+00	2025-02-14 10:48:29.894+00
variant_01JM214XJFTMSG53R69YR1HBBJ	pset_01JM214XKJ71Q9B4MDXS4DRNA9	pvps_01JM214XKZ65EYB80Z9YFFXV03	2025-02-14 10:47:53.726315+00	2025-02-14 10:48:29.894+00	2025-02-14 10:48:29.894+00
variant_01JM214XJFMZ7YMH9MAF05AVPK	pset_01JM214XKJDGN16P3MQAWZ3JX7	pvps_01JM214XKZ0PECSTAWDBQJJZJR	2025-02-14 10:47:53.726315+00	2025-02-14 10:48:29.894+00	2025-02-14 10:48:29.894+00
variant_01JM214XJF3BZDB5BQA0BA54VG	pset_01JM214XKJSGQN073K067E7QMV	pvps_01JM214XKZTGHF09E542YE1E1N	2025-02-14 10:47:53.726315+00	2025-02-14 10:48:29.894+00	2025-02-14 10:48:29.894+00
variant_01JM216BSVGFZBBP5NPYA769QS	pset_01JM216BV3JZTGTSZ1H8WETD98	pvps_01JM216BVEJ8NJ5M0XXTDJ5EAW	2025-02-14 10:48:41.068807+00	2025-02-14 13:52:56.937+00	2025-02-14 13:52:56.937+00
variant_01JM216BSV96MQJBFQRQJHK1CN	pset_01JM216BV3YDRZNZ1QTCHPW8DA	pvps_01JM216BVE4452WZ7JBJG1TD53	2025-02-14 10:48:41.068807+00	2025-02-14 13:52:56.937+00	2025-02-14 13:52:56.937+00
variant_01JM216BSVGC0REJX7DN9EHS1H	pset_01JM216BV305GERKPDNFNK7AGZ	pvps_01JM216BVEA97PPCGQEVE37DQ0	2025-02-14 10:48:41.068807+00	2025-02-14 13:52:56.937+00	2025-02-14 13:52:56.937+00
variant_01JM216BSV5TBZ324ZGN3S211G	pset_01JM216BV3R4Y407J8GSBZ7F5P	pvps_01JM216BVETRHYZ4GB30RP236P	2025-02-14 10:48:41.068807+00	2025-02-14 13:52:56.937+00	2025-02-14 13:52:56.937+00
variant_01JM216BSV8VX7G86TQJV8BMK8	pset_01JM216BV3KJW4F0MKQ5XHZ6XY	pvps_01JM216BVE410P484J8FXN0CRH	2025-02-14 10:48:41.068807+00	2025-02-14 13:52:56.937+00	2025-02-14 13:52:56.937+00
variant_01JM2BQZF6H12ZVV0E74KYHT7G	pset_01JM2BQZGFGKS34F1CSV8K3JAB	pvps_01JM2BQZH0QWPPFHCGAJBR0DEK	2025-02-14 13:53:04.030943+00	2025-02-14 13:54:44.393+00	2025-02-14 13:54:44.392+00
variant_01JM2BQZF61QEEJFQBR749C109	pset_01JM2BQZGF5MJ6S1NGFAS87N63	pvps_01JM2BQZGZ83G32DHBPZ7RXNEK	2025-02-14 13:53:04.030943+00	2025-02-14 13:54:50.826+00	2025-02-14 13:54:50.826+00
variant_01JM2BQZF62K4BM0W964MM00KN	pset_01JM2BQZGFQMTMF5Q3RGD1ABV2	pvps_01JM2BQZGZD53GV80TJZVBV1V9	2025-02-14 13:53:04.030943+00	2025-02-14 13:54:50.826+00	2025-02-14 13:54:50.826+00
variant_01JM2BQZF6C291VX9TQTBMJWAF	pset_01JM2BQZGFN6M5MGTDJTMEWKSW	pvps_01JM2BQZH0ZJMY7CQ91VEYSH5F	2025-02-14 13:53:04.030943+00	2025-02-14 13:54:50.826+00	2025-02-14 13:54:50.826+00
variant_01JM2BQZF637WXD2W0KYY79C75	pset_01JM2BQZGFSERRP34ES5BY0GRB	pvps_01JM2BQZH0G5F2XY2VX0P96JWR	2025-02-14 13:53:04.030943+00	2025-02-14 13:54:50.826+00	2025-02-14 13:54:50.826+00
variant_01JM2DWYKEH2R0T1VEWF5BBG02	pset_01JM2DWYMA1VS0FH5MYSVRX51V	pvps_01JM2DWYMNPFHBRTE3TNF5GG12	2025-02-14 14:30:44.123881+00	2025-02-14 14:33:33.711+00	2025-02-14 14:33:33.711+00
variant_01JM2DWYKEBJYSHGY3RBZCZHF1	pset_01JM2DWYMAGNM8H00H2KMGSS83	pvps_01JM2DWYMNASCPCC1HQMN77KWJ	2025-02-14 14:30:44.123881+00	2025-02-14 14:33:33.711+00	2025-02-14 14:33:33.711+00
variant_01JM2DWYKE0PGCT07XFQ88R40Z	pset_01JM2DWYMAE4XVH3K80986598Q	pvps_01JM2DWYMN3W1JX9SYBJHWMVKY	2025-02-14 14:30:44.123881+00	2025-02-14 14:33:33.711+00	2025-02-14 14:33:33.711+00
variant_01JM2DWYKFQ444FG22NHQ7E02Q	pset_01JM2DWYMACQFHAYKSSWTDWQKT	pvps_01JM2DWYMNYWRW9DZ1AAVN7C92	2025-02-14 14:30:44.123881+00	2025-02-14 14:33:33.711+00	2025-02-14 14:33:33.711+00
variant_01JM2E2AWJK67P0V6687Y9XDWK	pset_01JM2E2AXDQMHF62G3G6R10ZN8	pvps_01JM2E2AXQ3RJREMENPHCK4C49	2025-02-14 14:33:40.534649+00	2025-02-14 14:43:26.76+00	2025-02-14 14:43:26.759+00
variant_01JM2E2AWJ4MKAEG44N751P1V4	pset_01JM2E2AXDPP05VWZ0WQRW8WPS	pvps_01JM2E2AXQ9JFKWA7G9NVGW3Z8	2025-02-14 14:33:40.534649+00	2025-02-14 14:43:26.76+00	2025-02-14 14:43:26.759+00
variant_01JM2E2AWK5GRK72NAP1CZMYZV	pset_01JM2E2AXES10KFMQ6N9F0ERE9	pvps_01JM2E2AXQ19N62FG0XPCY4M9R	2025-02-14 14:33:40.534649+00	2025-02-14 14:43:26.76+00	2025-02-14 14:43:26.759+00
variant_01JM2E2AWKFZ9ZSSPZ9782C4AJ	pset_01JM2E2AXEWGDFJ0D7H4PH2AYP	pvps_01JM2E2AXQBPA4BEMBADNS9KTS	2025-02-14 14:33:40.534649+00	2025-02-14 14:43:26.76+00	2025-02-14 14:43:26.759+00
variant_01JM2E2AWKZJ0GD6SE7J9T6Y01	pset_01JM2E2AXE9SVWFCJAMGMJRGY9	pvps_01JM2E2AXQ67H3WCN14S16CEXR	2025-02-14 14:33:40.534649+00	2025-02-14 14:43:26.76+00	2025-02-14 14:43:26.759+00
variant_01JM2EME8J7YV9ZSM3S87RE2F1	pset_01JM2EME9EWCW4AW6CXW3YK4K2	pvps_01JM2EME9RTFXP1DQ72RT8ZNBV	2025-02-14 14:43:33.816205+00	2025-02-14 15:36:51.597+00	2025-02-14 15:36:51.597+00
variant_01JM2EME8J4Z2T3QWBPMV2J05B	pset_01JM2EME9E87QNQZVXMVF6ZQCT	pvps_01JM2EME9R0WM5BGBYD27G1ZJF	2025-02-14 14:43:33.816205+00	2025-02-14 15:36:51.597+00	2025-02-14 15:36:51.597+00
variant_01JM2EME8J4YT0973E3MC37691	pset_01JM2EME9EZ3TRZFMP6163GF4A	pvps_01JM2EME9SA01CXDH6VAY65BF4	2025-02-14 14:43:33.816205+00	2025-02-14 15:36:51.597+00	2025-02-14 15:36:51.597+00
variant_01JM2EME8JVG0NZC9HTGKA03M2	pset_01JM2EME9EZQQCXTXXXP9W4PVC	pvps_01JM2EME9SGT69R030040155R2	2025-02-14 14:43:33.816205+00	2025-02-14 15:36:51.597+00	2025-02-14 15:36:51.597+00
variant_01JM2EME8J8DDQ5TBX8QJD33FA	pset_01JM2EME9ERD3A7JGPVX0T7A09	pvps_01JM2EME9SWK8CF4SBFVXGVNHB	2025-02-14 14:43:33.816205+00	2025-02-14 15:36:51.597+00	2025-02-14 15:36:51.597+00
variant_01JM2HQQ7GXSRWQQ32FJKGK0KK	pset_01JM2HQQ933CP5KX61XNEK2BDG	pvps_01JM2HQQ9M8FVZDV0QT284EA3F	2025-02-14 15:37:47.060197+00	2025-02-14 15:39:13.467+00	2025-02-14 15:39:13.466+00
variant_01JM2HQQ7GJXZ171DBF284Q60W	pset_01JM2HQQ93SYRZZEESZWXMY62F	pvps_01JM2HQQ9NMTKEWDZVSS2C6SR4	2025-02-14 15:37:47.060197+00	2025-02-14 15:39:13.467+00	2025-02-14 15:39:13.466+00
variant_01JM2HQQ7GWGG9VH5FY6YQQ3QR	pset_01JM2HQQ936342CA71GC89FPFN	pvps_01JM2HQQ9N7QMZDZCM0E4JXX2N	2025-02-14 15:37:47.060197+00	2025-02-14 15:39:13.467+00	2025-02-14 15:39:13.466+00
variant_01JM2HQQ7GRSAFCJNWT0B6JQ81	pset_01JM2HQQ936J9KCSECC5SRG78R	pvps_01JM2HQQ9NKSVHNHC0G9VJKGQF	2025-02-14 15:37:47.060197+00	2025-02-14 15:39:13.467+00	2025-02-14 15:39:13.466+00
variant_01JM2HQQ7GHZ1ZA6GKAC1Q8ZED	pset_01JM2HQQ937VK3GM58VB7KHW9M	pvps_01JM2HQQ9NERBY2Y70X7V9S32R	2025-02-14 15:37:47.060197+00	2025-02-14 15:39:13.467+00	2025-02-14 15:39:13.466+00
variant_01JM2HTJ6V7G3AGXW9G8M8Z6J7	pset_01JM2HTJ7QR900WEWRMFAYENQK	pvps_01JM2HTJ82KGK21TZXTQ3XNX63	2025-02-14 15:39:20.194137+00	2025-02-14 15:42:36.537+00	2025-02-14 15:42:36.537+00
variant_01JM2HTJ6V33M12JK6F611PAM7	pset_01JM2HTJ7RG4TBNB593GSN48AT	pvps_01JM2HTJ8200G53XJ1TYEZQWB6	2025-02-14 15:39:20.194137+00	2025-02-14 15:42:36.537+00	2025-02-14 15:42:36.537+00
variant_01JM2HTJ6V2V12P1XC3H0PB4DH	pset_01JM2HTJ7RGWSRR2XA1C3TCEMR	pvps_01JM2HTJ83D4TMAXNX9NY7CV1T	2025-02-14 15:39:20.194137+00	2025-02-14 15:42:36.537+00	2025-02-14 15:42:36.537+00
variant_01JM2HTJ6W79908PTH99SR3NSH	pset_01JM2HTJ7RBGVADYJ177NC0DSR	pvps_01JM2HTJ83VA6CH5F794WAAJD3	2025-02-14 15:39:20.194137+00	2025-02-14 15:42:36.537+00	2025-02-14 15:42:36.537+00
variant_01JM2HTJ6WFMRW5HQFQQ64D5WD	pset_01JM2HTJ7RFF1YRQX8Z6VFT57T	pvps_01JM2HTJ83ZVVYHN0XB84DRM4T	2025-02-14 15:39:20.194137+00	2025-02-14 15:42:36.537+00	2025-02-14 15:42:36.537+00
variant_01JM2J0QEENMCCAYY13QY5W8GP	pset_01JM2J0QFDRDFNWBE3GTQSHCBB	pvps_01JM2J0QFQP9363CH61AKDWJC9	2025-02-14 15:42:42.166757+00	2025-02-14 15:49:16.216+00	2025-02-14 15:49:16.216+00
variant_01JM2J0QEEAWYPCC2MSNWPPYS6	pset_01JM2J0QFD58ZSJNR50SRMQZFD	pvps_01JM2J0QFRW20E3CR45X8Q0THT	2025-02-14 15:42:42.166757+00	2025-02-14 15:49:16.216+00	2025-02-14 15:49:16.216+00
variant_01JM2J0QEEH73GY3FCSJD39RGV	pset_01JM2J0QFDZAZP0E3PPQC3H8AP	pvps_01JM2J0QFRB6ZVHH9RSWE97GYD	2025-02-14 15:42:42.166757+00	2025-02-14 15:49:16.216+00	2025-02-14 15:49:16.216+00
variant_01JM2J0QEED1E9A2RT6VJC3P3J	pset_01JM2J0QFE9JRG8352R488K8J1	pvps_01JM2J0QFR90WV60CYB8FJJBF8	2025-02-14 15:42:42.166757+00	2025-02-14 15:49:16.216+00	2025-02-14 15:49:16.216+00
variant_01JM2J0QEER0962YW0Z7FAR8VE	pset_01JM2J0QFEXXPS40T2Q000GZVC	pvps_01JM2J0QFR09W565FKRM71QZKZ	2025-02-14 15:42:42.166757+00	2025-02-14 15:49:16.216+00	2025-02-14 15:49:16.216+00
variant_01JM2JD003PJTFMXYF8PMW04V1	pset_01JM2JD014XE4GMG5C8HA7BJT4	pvps_01JM2JD01EF021DZNW2FZN46AV	2025-02-14 15:49:24.141365+00	2025-02-14 15:52:43.012+00	2025-02-14 15:52:43.01+00
variant_01JM2JD0032G9NX9JVS5P9G7KG	pset_01JM2JD014ZQB4NR5ZTC7PVKFJ	pvps_01JM2JD01E7NCA7Y2TXW03F99J	2025-02-14 15:49:24.141365+00	2025-02-14 15:52:47.586+00	2025-02-14 15:52:47.586+00
variant_01JM2JD003RMCN6H3G57WB99B1	pset_01JM2JD0148VW1BT2MMFNFQ4K6	pvps_01JM2JD01EM12JGB931EXJPANE	2025-02-14 15:49:24.141365+00	2025-02-14 15:52:47.586+00	2025-02-14 15:52:47.586+00
variant_01JM2JD004FW0X9KYT2HFAR4B2	pset_01JM2JD014AFCS0RZC9HPMHEZX	pvps_01JM2JD01EFFG2RY8EN5HK12BR	2025-02-14 15:49:24.141365+00	2025-02-14 15:52:47.586+00	2025-02-14 15:52:47.586+00
variant_01JM2JD004DHSD3R5XVVDQYAY4	pset_01JM2JD014SDA8KRR2MCB9NYG8	pvps_01JM2JD01E2MDDEX9GDSWJ1T0B	2025-02-14 15:49:24.141365+00	2025-02-14 15:52:47.586+00	2025-02-14 15:52:47.586+00
variant_01JM2JKYQNQR247Y18RVTE1GWR	pset_01JM2JKYRMSZ8W0QR4XCDHG04X	pvps_01JM2JKYS2QD51DHVMY03DAG68	2025-02-14 15:53:12.22561+00	2025-02-14 16:01:40.512+00	2025-02-14 16:01:40.511+00
variant_01JM2JKYQNSXXS44RHCPNVDQS3	pset_01JM2JKYRMJFJ3704WSEBAJC9C	pvps_01JM2JKYS28Y597ZMYZJEA0HQC	2025-02-14 15:53:12.22561+00	2025-02-14 16:01:40.512+00	2025-02-14 16:01:40.511+00
variant_01JM2JKYQNZMT91TK6EG17D5JH	pset_01JM2JKYRMS20PVQMQXHYQJPW9	pvps_01JM2JKYS2MMYMJPHG2P8843YQ	2025-02-14 15:53:12.22561+00	2025-02-14 16:01:40.512+00	2025-02-14 16:01:40.511+00
variant_01JM2JKYQNYAFP7PK83XWSH3D3	pset_01JM2JKYRMWNRBN1SYMA77BQNM	pvps_01JM2JKYS2MXD09ENPAZ09YV04	2025-02-14 15:53:12.22561+00	2025-02-14 16:01:40.512+00	2025-02-14 16:01:40.511+00
variant_01JM2JKYQNY1XXEMVAX6H0PPC6	pset_01JM2JKYRNGP83N1PP02E2KQEQ	pvps_01JM2JKYS24E1N6PJ5TJ75RXJH	2025-02-14 15:53:12.22561+00	2025-02-14 16:01:40.512+00	2025-02-14 16:01:40.511+00
variant_01JM2K3ZSC3JK012FDYS2GD146	pset_01JM2K3ZTA2Z4D9WQQCB4ADWVJ	pvps_01JM2K3ZTNGSSTSMDDW93AK6JX	2025-02-14 16:01:57.588742+00	2025-02-14 16:01:57.588742+00	\N
variant_01JM2K3ZSDXRS6ED0N6TJAE31K	pset_01JM2K3ZTASXNXFFF25J55ZTMH	pvps_01JM2K3ZTNN5CPTMNMXA393AGJ	2025-02-14 16:01:57.588742+00	2025-02-14 16:01:57.588742+00	\N
variant_01JM2K3ZSD4MM311EXN487TMX6	pset_01JM2K3ZTBH9A7KFAVKBJPB0PC	pvps_01JM2K3ZTNKBJ4TN76J4BRHZF1	2025-02-14 16:01:57.588742+00	2025-02-14 16:01:57.588742+00	\N
variant_01JM2K3ZSDF0SD3GRCA3ZJMFS2	pset_01JM2K3ZTBEN1DRC46JZEJVE1H	pvps_01JM2K3ZTN8YX78HVV6D04S9XN	2025-02-14 16:01:57.588742+00	2025-02-14 16:01:57.588742+00	\N
variant_01JM2K3ZSD3B6MS40VCPVRDWAJ	pset_01JM2K3ZTB1MQ2B34EJV4G6BEA	pvps_01JM2K3ZTNJ0TV4V2HPX75GHQX	2025-02-14 16:01:57.588742+00	2025-02-14 16:01:57.588742+00	\N
\.


--
-- Data for Name: promotion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion (id, code, campaign_id, is_automatic, type, created_at, updated_at, deleted_at, status) FROM stdin;
\.


--
-- Data for Name: promotion_application_method; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_application_method (id, value, raw_value, max_quantity, apply_to_quantity, buy_rules_min_quantity, type, target_type, allocation, promotion_id, created_at, updated_at, deleted_at, currency_code) FROM stdin;
\.


--
-- Data for Name: promotion_campaign; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_campaign (id, name, description, campaign_identifier, starts_at, ends_at, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_campaign_budget; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_campaign_budget (id, type, campaign_id, "limit", raw_limit, used, raw_used, created_at, updated_at, deleted_at, currency_code) FROM stdin;
\.


--
-- Data for Name: promotion_promotion_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_promotion_rule (promotion_id, promotion_rule_id) FROM stdin;
\.


--
-- Data for Name: promotion_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_rule (id, description, attribute, operator, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: promotion_rule_value; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.promotion_rule_value (id, promotion_rule_id, value, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: provider_identity; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.provider_identity (id, entity_id, provider, auth_identity_id, user_metadata, provider_metadata, created_at, updated_at, deleted_at) FROM stdin;
01JM18EDN6H8XV5JZ0H0CS13E3	hieunguyenel@gmail.com	emailpass	authid_01JM18EDN6FQJ72ZAEVRK8152P	\N	{"password": "c2NyeXB0AA8AAAAIAAAAAbpGU0SDVkyiXPwOF93zkZw09UIlx72LnpLd/qi+ORwgZQhfn2ekF6VlmlsoUdS6P6w5j/tMi/NN9+QoW7WZTP98D9ybupHPnAcOV1riQr7I"}	2025-02-14 03:36:10.663+00	2025-02-14 03:36:10.663+00	\N
\.


--
-- Data for Name: publishable_api_key_sales_channel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.publishable_api_key_sales_channel (publishable_key_id, sales_channel_id, id, created_at, updated_at, deleted_at) FROM stdin;
apk_01JM18DSHY8A33T4ZEH21XJHE9	sc_01JM18DQRAB13QQK6V7535YDR1	pksc_01JM18DSJ4YC98HS19PRKDBQ7F	2025-02-14 03:35:50.083806+00	2025-02-14 03:35:50.083806+00	\N
\.


--
-- Data for Name: refund; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refund (id, amount, raw_amount, payment_id, created_at, updated_at, deleted_at, created_by, metadata, refund_reason_id, note) FROM stdin;
\.


--
-- Data for Name: refund_reason; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.refund_reason (id, label, description, metadata, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: region; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.region (id, name, currency_code, metadata, created_at, updated_at, deleted_at, automatic_taxes) FROM stdin;
reg_01JM18DSE1Q94XA80ZWJXQ58J3	Europe	eur	\N	2025-02-14 03:35:49.96+00	2025-02-14 03:35:49.96+00	\N	t
\.


--
-- Data for Name: region_country; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.region_country (iso_2, iso_3, num_code, name, display_name, region_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
af	afg	004	AFGHANISTAN	Afghanistan	\N	\N	2025-02-14 03:35:46.008+00	2025-02-14 03:35:46.008+00	\N
al	alb	008	ALBANIA	Albania	\N	\N	2025-02-14 03:35:46.008+00	2025-02-14 03:35:46.008+00	\N
dz	dza	012	ALGERIA	Algeria	\N	\N	2025-02-14 03:35:46.008+00	2025-02-14 03:35:46.008+00	\N
as	asm	016	AMERICAN SAMOA	American Samoa	\N	\N	2025-02-14 03:35:46.008+00	2025-02-14 03:35:46.008+00	\N
ad	and	020	ANDORRA	Andorra	\N	\N	2025-02-14 03:35:46.008+00	2025-02-14 03:35:46.008+00	\N
ao	ago	024	ANGOLA	Angola	\N	\N	2025-02-14 03:35:46.008+00	2025-02-14 03:35:46.008+00	\N
ai	aia	660	ANGUILLA	Anguilla	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
aq	ata	010	ANTARCTICA	Antarctica	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ag	atg	028	ANTIGUA AND BARBUDA	Antigua and Barbuda	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ar	arg	032	ARGENTINA	Argentina	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
am	arm	051	ARMENIA	Armenia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
aw	abw	533	ARUBA	Aruba	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
au	aus	036	AUSTRALIA	Australia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
at	aut	040	AUSTRIA	Austria	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
az	aze	031	AZERBAIJAN	Azerbaijan	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bs	bhs	044	BAHAMAS	Bahamas	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bh	bhr	048	BAHRAIN	Bahrain	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bd	bgd	050	BANGLADESH	Bangladesh	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bb	brb	052	BARBADOS	Barbados	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
by	blr	112	BELARUS	Belarus	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
be	bel	056	BELGIUM	Belgium	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bz	blz	084	BELIZE	Belize	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bj	ben	204	BENIN	Benin	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bm	bmu	060	BERMUDA	Bermuda	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bt	btn	064	BHUTAN	Bhutan	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bo	bol	068	BOLIVIA	Bolivia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bq	bes	535	BONAIRE, SINT EUSTATIUS AND SABA	Bonaire, Sint Eustatius and Saba	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ba	bih	070	BOSNIA AND HERZEGOVINA	Bosnia and Herzegovina	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bw	bwa	072	BOTSWANA	Botswana	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bv	bvd	074	BOUVET ISLAND	Bouvet Island	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
br	bra	076	BRAZIL	Brazil	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
io	iot	086	BRITISH INDIAN OCEAN TERRITORY	British Indian Ocean Territory	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bn	brn	096	BRUNEI DARUSSALAM	Brunei Darussalam	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bg	bgr	100	BULGARIA	Bulgaria	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bf	bfa	854	BURKINA FASO	Burkina Faso	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
bi	bdi	108	BURUNDI	Burundi	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
kh	khm	116	CAMBODIA	Cambodia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cm	cmr	120	CAMEROON	Cameroon	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ca	can	124	CANADA	Canada	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cv	cpv	132	CAPE VERDE	Cape Verde	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ky	cym	136	CAYMAN ISLANDS	Cayman Islands	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cf	caf	140	CENTRAL AFRICAN REPUBLIC	Central African Republic	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
td	tcd	148	CHAD	Chad	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cl	chl	152	CHILE	Chile	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cn	chn	156	CHINA	China	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cx	cxr	162	CHRISTMAS ISLAND	Christmas Island	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cc	cck	166	COCOS (KEELING) ISLANDS	Cocos (Keeling) Islands	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
co	col	170	COLOMBIA	Colombia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
km	com	174	COMOROS	Comoros	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cg	cog	178	CONGO	Congo	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cd	cod	180	CONGO, THE DEMOCRATIC REPUBLIC OF THE	Congo, the Democratic Republic of the	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ck	cok	184	COOK ISLANDS	Cook Islands	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cr	cri	188	COSTA RICA	Costa Rica	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ci	civ	384	COTE D'IVOIRE	Cote D'Ivoire	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
hr	hrv	191	CROATIA	Croatia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cu	cub	192	CUBA	Cuba	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cw	cuw	531	CURAÇAO	Curaçao	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cy	cyp	196	CYPRUS	Cyprus	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
cz	cze	203	CZECH REPUBLIC	Czech Republic	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
dj	dji	262	DJIBOUTI	Djibouti	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
dm	dma	212	DOMINICA	Dominica	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
do	dom	214	DOMINICAN REPUBLIC	Dominican Republic	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ec	ecu	218	ECUADOR	Ecuador	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
eg	egy	818	EGYPT	Egypt	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
sv	slv	222	EL SALVADOR	El Salvador	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gq	gnq	226	EQUATORIAL GUINEA	Equatorial Guinea	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
er	eri	232	ERITREA	Eritrea	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ee	est	233	ESTONIA	Estonia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
et	eth	231	ETHIOPIA	Ethiopia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
fk	flk	238	FALKLAND ISLANDS (MALVINAS)	Falkland Islands (Malvinas)	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
fo	fro	234	FAROE ISLANDS	Faroe Islands	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
fj	fji	242	FIJI	Fiji	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
fi	fin	246	FINLAND	Finland	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gf	guf	254	FRENCH GUIANA	French Guiana	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
pf	pyf	258	FRENCH POLYNESIA	French Polynesia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
tf	atf	260	FRENCH SOUTHERN TERRITORIES	French Southern Territories	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ga	gab	266	GABON	Gabon	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gm	gmb	270	GAMBIA	Gambia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ge	geo	268	GEORGIA	Georgia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gh	gha	288	GHANA	Ghana	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gi	gib	292	GIBRALTAR	Gibraltar	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gr	grc	300	GREECE	Greece	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gl	grl	304	GREENLAND	Greenland	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gd	grd	308	GRENADA	Grenada	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gp	glp	312	GUADELOUPE	Guadeloupe	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gu	gum	316	GUAM	Guam	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gt	gtm	320	GUATEMALA	Guatemala	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gg	ggy	831	GUERNSEY	Guernsey	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gn	gin	324	GUINEA	Guinea	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gw	gnb	624	GUINEA-BISSAU	Guinea-Bissau	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
gy	guy	328	GUYANA	Guyana	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ht	hti	332	HAITI	Haiti	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
hm	hmd	334	HEARD ISLAND AND MCDONALD ISLANDS	Heard Island And Mcdonald Islands	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
va	vat	336	HOLY SEE (VATICAN CITY STATE)	Holy See (Vatican City State)	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
hn	hnd	340	HONDURAS	Honduras	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
hk	hkg	344	HONG KONG	Hong Kong	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
hu	hun	348	HUNGARY	Hungary	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
is	isl	352	ICELAND	Iceland	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
in	ind	356	INDIA	India	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
id	idn	360	INDONESIA	Indonesia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ir	irn	364	IRAN, ISLAMIC REPUBLIC OF	Iran, Islamic Republic of	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
iq	irq	368	IRAQ	Iraq	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ie	irl	372	IRELAND	Ireland	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
im	imn	833	ISLE OF MAN	Isle Of Man	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
il	isr	376	ISRAEL	Israel	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
jm	jam	388	JAMAICA	Jamaica	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
jp	jpn	392	JAPAN	Japan	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
je	jey	832	JERSEY	Jersey	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
jo	jor	400	JORDAN	Jordan	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
kz	kaz	398	KAZAKHSTAN	Kazakhstan	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ke	ken	404	KENYA	Kenya	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ki	kir	296	KIRIBATI	Kiribati	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
kp	prk	408	KOREA, DEMOCRATIC PEOPLE'S REPUBLIC OF	Korea, Democratic People's Republic of	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
kr	kor	410	KOREA, REPUBLIC OF	Korea, Republic of	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
xk	xkx	900	KOSOVO	Kosovo	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
kw	kwt	414	KUWAIT	Kuwait	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
kg	kgz	417	KYRGYZSTAN	Kyrgyzstan	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
la	lao	418	LAO PEOPLE'S DEMOCRATIC REPUBLIC	Lao People's Democratic Republic	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
lv	lva	428	LATVIA	Latvia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
lb	lbn	422	LEBANON	Lebanon	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ls	lso	426	LESOTHO	Lesotho	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
lr	lbr	430	LIBERIA	Liberia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ly	lby	434	LIBYA	Libya	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
li	lie	438	LIECHTENSTEIN	Liechtenstein	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
lt	ltu	440	LITHUANIA	Lithuania	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
lu	lux	442	LUXEMBOURG	Luxembourg	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mo	mac	446	MACAO	Macao	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mk	mkd	807	MACEDONIA, THE FORMER YUGOSLAV REPUBLIC OF	Macedonia, the Former Yugoslav Republic of	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mg	mdg	450	MADAGASCAR	Madagascar	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mw	mwi	454	MALAWI	Malawi	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
my	mys	458	MALAYSIA	Malaysia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mv	mdv	462	MALDIVES	Maldives	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ml	mli	466	MALI	Mali	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mt	mlt	470	MALTA	Malta	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mh	mhl	584	MARSHALL ISLANDS	Marshall Islands	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mq	mtq	474	MARTINIQUE	Martinique	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mr	mrt	478	MAURITANIA	Mauritania	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mu	mus	480	MAURITIUS	Mauritius	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
yt	myt	175	MAYOTTE	Mayotte	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mx	mex	484	MEXICO	Mexico	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
fm	fsm	583	MICRONESIA, FEDERATED STATES OF	Micronesia, Federated States of	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
md	mda	498	MOLDOVA, REPUBLIC OF	Moldova, Republic of	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mc	mco	492	MONACO	Monaco	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mn	mng	496	MONGOLIA	Mongolia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
me	mne	499	MONTENEGRO	Montenegro	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ms	msr	500	MONTSERRAT	Montserrat	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
ma	mar	504	MOROCCO	Morocco	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mz	moz	508	MOZAMBIQUE	Mozambique	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
mm	mmr	104	MYANMAR	Myanmar	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
na	nam	516	NAMIBIA	Namibia	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
nr	nru	520	NAURU	Nauru	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
np	npl	524	NEPAL	Nepal	\N	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:46.009+00	\N
nl	nld	528	NETHERLANDS	Netherlands	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
nc	ncl	540	NEW CALEDONIA	New Caledonia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
nz	nzl	554	NEW ZEALAND	New Zealand	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ni	nic	558	NICARAGUA	Nicaragua	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ne	ner	562	NIGER	Niger	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ng	nga	566	NIGERIA	Nigeria	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
nu	niu	570	NIUE	Niue	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
nf	nfk	574	NORFOLK ISLAND	Norfolk Island	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
mp	mnp	580	NORTHERN MARIANA ISLANDS	Northern Mariana Islands	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
no	nor	578	NORWAY	Norway	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
om	omn	512	OMAN	Oman	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pk	pak	586	PAKISTAN	Pakistan	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pw	plw	585	PALAU	Palau	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ps	pse	275	PALESTINIAN TERRITORY, OCCUPIED	Palestinian Territory, Occupied	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pa	pan	591	PANAMA	Panama	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pg	png	598	PAPUA NEW GUINEA	Papua New Guinea	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
py	pry	600	PARAGUAY	Paraguay	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pe	per	604	PERU	Peru	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ph	phl	608	PHILIPPINES	Philippines	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pn	pcn	612	PITCAIRN	Pitcairn	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pl	pol	616	POLAND	Poland	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pt	prt	620	PORTUGAL	Portugal	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pr	pri	630	PUERTO RICO	Puerto Rico	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
qa	qat	634	QATAR	Qatar	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
re	reu	638	REUNION	Reunion	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ro	rom	642	ROMANIA	Romania	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ru	rus	643	RUSSIAN FEDERATION	Russian Federation	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
rw	rwa	646	RWANDA	Rwanda	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
bl	blm	652	SAINT BARTHÉLEMY	Saint Barthélemy	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sh	shn	654	SAINT HELENA	Saint Helena	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
kn	kna	659	SAINT KITTS AND NEVIS	Saint Kitts and Nevis	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
lc	lca	662	SAINT LUCIA	Saint Lucia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
mf	maf	663	SAINT MARTIN (FRENCH PART)	Saint Martin (French part)	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
pm	spm	666	SAINT PIERRE AND MIQUELON	Saint Pierre and Miquelon	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
vc	vct	670	SAINT VINCENT AND THE GRENADINES	Saint Vincent and the Grenadines	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ws	wsm	882	SAMOA	Samoa	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sm	smr	674	SAN MARINO	San Marino	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
st	stp	678	SAO TOME AND PRINCIPE	Sao Tome and Principe	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sa	sau	682	SAUDI ARABIA	Saudi Arabia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sn	sen	686	SENEGAL	Senegal	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
rs	srb	688	SERBIA	Serbia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sc	syc	690	SEYCHELLES	Seychelles	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sl	sle	694	SIERRA LEONE	Sierra Leone	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sg	sgp	702	SINGAPORE	Singapore	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sx	sxm	534	SINT MAARTEN	Sint Maarten	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sk	svk	703	SLOVAKIA	Slovakia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
si	svn	705	SLOVENIA	Slovenia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sb	slb	090	SOLOMON ISLANDS	Solomon Islands	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
so	som	706	SOMALIA	Somalia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
za	zaf	710	SOUTH AFRICA	South Africa	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
gs	sgs	239	SOUTH GEORGIA AND THE SOUTH SANDWICH ISLANDS	South Georgia and the South Sandwich Islands	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ss	ssd	728	SOUTH SUDAN	South Sudan	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
lk	lka	144	SRI LANKA	Sri Lanka	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sd	sdn	729	SUDAN	Sudan	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sr	sur	740	SURINAME	Suriname	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sj	sjm	744	SVALBARD AND JAN MAYEN	Svalbard and Jan Mayen	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sz	swz	748	SWAZILAND	Swaziland	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ch	che	756	SWITZERLAND	Switzerland	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
sy	syr	760	SYRIAN ARAB REPUBLIC	Syrian Arab Republic	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tw	twn	158	TAIWAN, PROVINCE OF CHINA	Taiwan, Province of China	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tj	tjk	762	TAJIKISTAN	Tajikistan	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tz	tza	834	TANZANIA, UNITED REPUBLIC OF	Tanzania, United Republic of	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
th	tha	764	THAILAND	Thailand	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tl	tls	626	TIMOR LESTE	Timor Leste	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tg	tgo	768	TOGO	Togo	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tk	tkl	772	TOKELAU	Tokelau	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
to	ton	776	TONGA	Tonga	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tt	tto	780	TRINIDAD AND TOBAGO	Trinidad and Tobago	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tn	tun	788	TUNISIA	Tunisia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tr	tur	792	TURKEY	Turkey	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tm	tkm	795	TURKMENISTAN	Turkmenistan	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tc	tca	796	TURKS AND CAICOS ISLANDS	Turks and Caicos Islands	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
tv	tuv	798	TUVALU	Tuvalu	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ug	uga	800	UGANDA	Uganda	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ua	ukr	804	UKRAINE	Ukraine	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ae	are	784	UNITED ARAB EMIRATES	United Arab Emirates	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
us	usa	840	UNITED STATES	United States	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
um	umi	581	UNITED STATES MINOR OUTLYING ISLANDS	United States Minor Outlying Islands	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
uy	ury	858	URUGUAY	Uruguay	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
uz	uzb	860	UZBEKISTAN	Uzbekistan	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
vu	vut	548	VANUATU	Vanuatu	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ve	ven	862	VENEZUELA	Venezuela	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
vn	vnm	704	VIET NAM	Viet Nam	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
vg	vgb	092	VIRGIN ISLANDS, BRITISH	Virgin Islands, British	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
vi	vir	850	VIRGIN ISLANDS, U.S.	Virgin Islands, U.S.	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
wf	wlf	876	WALLIS AND FUTUNA	Wallis and Futuna	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
eh	esh	732	WESTERN SAHARA	Western Sahara	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ye	yem	887	YEMEN	Yemen	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
zm	zmb	894	ZAMBIA	Zambia	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
zw	zwe	716	ZIMBABWE	Zimbabwe	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
ax	ala	248	ÅLAND ISLANDS	Åland Islands	\N	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:46.01+00	\N
dk	dnk	208	DENMARK	Denmark	reg_01JM18DSE1Q94XA80ZWJXQ58J3	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:49.96+00	\N
fr	fra	250	FRANCE	France	reg_01JM18DSE1Q94XA80ZWJXQ58J3	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:49.96+00	\N
de	deu	276	GERMANY	Germany	reg_01JM18DSE1Q94XA80ZWJXQ58J3	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:49.96+00	\N
it	ita	380	ITALY	Italy	reg_01JM18DSE1Q94XA80ZWJXQ58J3	\N	2025-02-14 03:35:46.009+00	2025-02-14 03:35:49.96+00	\N
es	esp	724	SPAIN	Spain	reg_01JM18DSE1Q94XA80ZWJXQ58J3	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:49.96+00	\N
se	swe	752	SWEDEN	Sweden	reg_01JM18DSE1Q94XA80ZWJXQ58J3	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:49.96+00	\N
gb	gbr	826	UNITED KINGDOM	United Kingdom	reg_01JM18DSE1Q94XA80ZWJXQ58J3	\N	2025-02-14 03:35:46.01+00	2025-02-14 03:35:49.96+00	\N
\.


--
-- Data for Name: region_payment_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.region_payment_provider (region_id, payment_provider_id, id, created_at, updated_at, deleted_at) FROM stdin;
reg_01JM18DSE1Q94XA80ZWJXQ58J3	pp_system_default	regpp_01JM18DSEPH3G7S8ZPB3H2BRS3	2025-02-14 03:35:49.973654+00	2025-02-14 03:35:49.973654+00	\N
\.


--
-- Data for Name: reservation_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.reservation_item (id, created_at, updated_at, deleted_at, line_item_id, location_id, quantity, external_id, description, created_by, metadata, inventory_item_id, allow_backorder, raw_quantity) FROM stdin;
\.


--
-- Data for Name: return; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return (id, order_id, claim_id, exchange_id, order_version, display_id, status, no_notification, refund_amount, raw_refund_amount, metadata, created_at, updated_at, deleted_at, received_at, canceled_at, location_id, requested_at, created_by) FROM stdin;
\.


--
-- Data for Name: return_fulfillment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return_fulfillment (return_id, fulfillment_id, id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: return_item; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return_item (id, return_id, reason_id, item_id, quantity, raw_quantity, received_quantity, raw_received_quantity, note, metadata, created_at, updated_at, deleted_at, damaged_quantity, raw_damaged_quantity) FROM stdin;
\.


--
-- Data for Name: return_reason; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.return_reason (id, value, label, description, metadata, parent_return_reason_id, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: sales_channel; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_channel (id, name, description, is_disabled, metadata, created_at, updated_at, deleted_at) FROM stdin;
sc_01JM18DQRAB13QQK6V7535YDR1	Default Sales Channel	Created by Medusa	f	\N	2025-02-14 03:35:48.234+00	2025-02-14 03:35:48.234+00	\N
\.


--
-- Data for Name: sales_channel_stock_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sales_channel_stock_location (sales_channel_id, stock_location_id, id, created_at, updated_at, deleted_at) FROM stdin;
sc_01JM18DQRAB13QQK6V7535YDR1	sloc_01JM18DSF42Z07ZVKW86JAM4XR	scloc_01JM18DSHST7PQ46VCJJA6R7ME	2025-02-14 03:35:50.071993+00	2025-02-14 03:35:50.071993+00	\N
\.


--
-- Data for Name: script_migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.script_migrations (id, script_name, created_at, finished_at) FROM stdin;
1	migrate-product-shipping-profile.js	2025-02-14 03:35:46.584769+00	2025-02-14 03:35:46.601139+00
\.


--
-- Data for Name: service_zone; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.service_zone (id, name, metadata, fulfillment_set_id, created_at, updated_at, deleted_at) FROM stdin;
serzo_01JM18DSFMBSKMFFS6KCMP4C7P	Europe	\N	fuset_01JM18DSFMAVM37G1C672XYWBZ	2025-02-14 03:35:50.004+00	2025-02-14 03:35:50.004+00	\N
\.


--
-- Data for Name: shipping_option; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_option (id, name, price_type, service_zone_id, shipping_profile_id, provider_id, data, metadata, shipping_option_type_id, created_at, updated_at, deleted_at) FROM stdin;
so_01JM18DSGMCCHDTBGA65B12C9N	Standard Shipping	flat	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	sp_01JM18DSFFZW6A3X2BVSRWHYAK	manual_manual	\N	\N	sotype_01JM18DSGK88KF3GXP1Y7FFV1N	2025-02-14 03:35:50.036+00	2025-02-14 03:35:50.036+00	\N
so_01JM18DSGMPXYXEAYZTSKCM7XZ	Express Shipping	flat	serzo_01JM18DSFMBSKMFFS6KCMP4C7P	sp_01JM18DSFFZW6A3X2BVSRWHYAK	manual_manual	\N	\N	sotype_01JM18DSGMYKQSJDR9Z55P2SCY	2025-02-14 03:35:50.036+00	2025-02-14 03:35:50.036+00	\N
\.


--
-- Data for Name: shipping_option_price_set; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_option_price_set (shipping_option_id, price_set_id, id, created_at, updated_at, deleted_at) FROM stdin;
so_01JM18DSGMCCHDTBGA65B12C9N	pset_01JM18DSH16AVHD8SRS6CCBZKD	sops_01JM18DSHKECTNG0RHKWQSGVBC	2025-02-14 03:35:50.066788+00	2025-02-14 03:35:50.066788+00	\N
so_01JM18DSGMPXYXEAYZTSKCM7XZ	pset_01JM18DSH1SEMHRMD26G6ZBAPH	sops_01JM18DSHMS3C67R7T0CD7A54Q	2025-02-14 03:35:50.066788+00	2025-02-14 03:35:50.066788+00	\N
\.


--
-- Data for Name: shipping_option_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_option_rule (id, attribute, operator, value, shipping_option_id, created_at, updated_at, deleted_at) FROM stdin;
sorul_01JM18DSGMQEDNVTM68WR5DHMA	enabled_in_store	eq	"true"	so_01JM18DSGMCCHDTBGA65B12C9N	2025-02-14 03:35:50.037+00	2025-02-14 03:35:50.037+00	\N
sorul_01JM18DSGME85CTMFE5QHY6PZT	is_return	eq	"false"	so_01JM18DSGMCCHDTBGA65B12C9N	2025-02-14 03:35:50.037+00	2025-02-14 03:35:50.037+00	\N
sorul_01JM18DSGM8P5GGMSCMGK631RF	enabled_in_store	eq	"true"	so_01JM18DSGMPXYXEAYZTSKCM7XZ	2025-02-14 03:35:50.037+00	2025-02-14 03:35:50.037+00	\N
sorul_01JM18DSGMV8MS28WVMJWE2JZ9	is_return	eq	"false"	so_01JM18DSGMPXYXEAYZTSKCM7XZ	2025-02-14 03:35:50.037+00	2025-02-14 03:35:50.037+00	\N
\.


--
-- Data for Name: shipping_option_type; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_option_type (id, label, description, code, created_at, updated_at, deleted_at) FROM stdin;
sotype_01JM18DSGK88KF3GXP1Y7FFV1N	Standard	Ship in 2-3 days.	standard	2025-02-14 03:35:50.036+00	2025-02-14 03:35:50.036+00	\N
sotype_01JM18DSGMYKQSJDR9Z55P2SCY	Express	Ship in 24 hours.	express	2025-02-14 03:35:50.036+00	2025-02-14 03:35:50.036+00	\N
\.


--
-- Data for Name: shipping_profile; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shipping_profile (id, name, type, metadata, created_at, updated_at, deleted_at) FROM stdin;
sp_01JM18DP54DYXKECZZZ26Z9CYJ	Default Shipping Profile	default	\N	2025-02-14 03:35:46.597+00	2025-02-14 03:35:46.597+00	\N
sp_01JM18DSFFZW6A3X2BVSRWHYAK	Default	default	\N	2025-02-14 03:35:49.999+00	2025-02-14 03:35:49.999+00	\N
\.


--
-- Data for Name: stock_location; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_location (id, created_at, updated_at, deleted_at, name, address_id, metadata) FROM stdin;
sloc_01JM18DSF42Z07ZVKW86JAM4XR	2025-02-14 03:35:49.988+00	2025-02-14 03:35:49.988+00	\N	European Warehouse	laddr_01JM18DSF4MWJ93W5RRDCTCFFJ	\N
\.


--
-- Data for Name: stock_location_address; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_location_address (id, created_at, updated_at, deleted_at, address_1, address_2, company, city, country_code, phone, province, postal_code, metadata) FROM stdin;
laddr_01JM18DSF4MWJ93W5RRDCTCFFJ	2025-02-14 03:35:49.988+00	2025-02-14 03:35:49.988+00	\N		\N	\N	Copenhagen	DK	\N	\N	\N	\N
\.


--
-- Data for Name: store; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store (id, name, default_sales_channel_id, default_region_id, default_location_id, metadata, created_at, updated_at, deleted_at) FROM stdin;
store_01JM18DQRNR1AF0QE4AF0CR3NE	Medusa Store	sc_01JM18DQRAB13QQK6V7535YDR1	\N	\N	\N	2025-02-14 03:35:48.243563+00	2025-02-14 03:35:48.243563+00	\N
\.


--
-- Data for Name: store_currency; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.store_currency (id, currency_code, is_default, store_id, created_at, updated_at, deleted_at) FROM stdin;
stocur_01JM18DSDDEJR8E4W0H005PPC8	eur	t	store_01JM18DQRNR1AF0QE4AF0CR3NE	2025-02-14 03:35:49.928715+00	2025-02-14 03:35:49.928715+00	\N
stocur_01JM18DSDDWHY20F6SQ090AQCK	usd	f	store_01JM18DQRNR1AF0QE4AF0CR3NE	2025-02-14 03:35:49.928715+00	2025-02-14 03:35:49.928715+00	\N
\.


--
-- Data for Name: tax_provider; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tax_provider (id, is_enabled, created_at, updated_at, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_rate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tax_rate (id, rate, code, name, is_default, is_combinable, tax_region_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_rate_rule; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tax_rate_rule (id, tax_rate_id, reference_id, reference, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
\.


--
-- Data for Name: tax_region; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.tax_region (id, provider_id, country_code, province_code, parent_id, metadata, created_at, updated_at, created_by, deleted_at) FROM stdin;
txreg_01JM18DSEX7NQ98SS56W2WN4RV	\N	gb	\N	\N	\N	2025-02-14 03:35:49.981+00	2025-02-14 03:35:49.981+00	\N	\N
txreg_01JM18DSEXZ0DVADSRA7GWRACK	\N	de	\N	\N	\N	2025-02-14 03:35:49.981+00	2025-02-14 03:35:49.981+00	\N	\N
txreg_01JM18DSEXZ9NJ7WQ7H8SP3FHG	\N	dk	\N	\N	\N	2025-02-14 03:35:49.981+00	2025-02-14 03:35:49.981+00	\N	\N
txreg_01JM18DSEX812HNDYWWS6ZCFHS	\N	se	\N	\N	\N	2025-02-14 03:35:49.981+00	2025-02-14 03:35:49.981+00	\N	\N
txreg_01JM18DSEX4ZQGFNTP2SY71YZQ	\N	fr	\N	\N	\N	2025-02-14 03:35:49.981+00	2025-02-14 03:35:49.981+00	\N	\N
txreg_01JM18DSEX1F3HF3JRNP3NGY4E	\N	es	\N	\N	\N	2025-02-14 03:35:49.981+00	2025-02-14 03:35:49.981+00	\N	\N
txreg_01JM18DSEX6Y761ET7EZK3AB4R	\N	it	\N	\N	\N	2025-02-14 03:35:49.981+00	2025-02-14 03:35:49.981+00	\N	\N
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public."user" (id, first_name, last_name, email, avatar_url, metadata, created_at, updated_at, deleted_at) FROM stdin;
user_01JM18EDP3GPD7FCRAZJ18FVS3	hieu	nguyen	hieunguyenel@gmail.com	\N	\N	2025-02-14 03:36:10.691+00	2025-02-14 03:36:10.691+00	\N
\.


--
-- Data for Name: workflow_execution; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workflow_execution (id, workflow_id, transaction_id, execution, context, state, created_at, updated_at, deleted_at, retention_time) FROM stdin;
\.


--
-- Name: link_module_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.link_module_migrations_id_seq', 18, true);


--
-- Name: mikro_orm_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.mikro_orm_migrations_id_seq', 98, true);


--
-- Name: order_change_action_ordering_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_change_action_ordering_seq', 1, false);


--
-- Name: order_claim_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_claim_display_id_seq', 1, false);


--
-- Name: order_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_display_id_seq', 1, false);


--
-- Name: order_exchange_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_exchange_display_id_seq', 1, false);


--
-- Name: return_display_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.return_display_id_seq', 1, false);


--
-- Name: script_migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.script_migrations_id_seq', 1, true);


--
-- Name: promotion IDX_promotion_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT "IDX_promotion_code_unique" UNIQUE (code);


--
-- Name: workflow_execution PK_workflow_execution_workflow_id_transaction_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workflow_execution
    ADD CONSTRAINT "PK_workflow_execution_workflow_id_transaction_id" PRIMARY KEY (workflow_id, transaction_id);


--
-- Name: account_holder account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.account_holder
    ADD CONSTRAINT account_holder_pkey PRIMARY KEY (id);


--
-- Name: api_key api_key_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.api_key
    ADD CONSTRAINT api_key_pkey PRIMARY KEY (id);


--
-- Name: application_method_buy_rules application_method_buy_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: application_method_target_rules application_method_target_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_pkey PRIMARY KEY (application_method_id, promotion_rule_id);


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY (id);


--
-- Name: capture capture_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_pkey PRIMARY KEY (id);


--
-- Name: cart_address cart_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_address
    ADD CONSTRAINT cart_address_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item cart_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_pkey PRIMARY KEY (id);


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: cart_payment_collection cart_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_payment_collection
    ADD CONSTRAINT cart_payment_collection_pkey PRIMARY KEY (cart_id, payment_collection_id);


--
-- Name: cart cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_pkey PRIMARY KEY (id);


--
-- Name: cart_promotion cart_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_promotion
    ADD CONSTRAINT cart_promotion_pkey PRIMARY KEY (cart_id, promotion_id);


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method cart_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: currency currency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.currency
    ADD CONSTRAINT currency_pkey PRIMARY KEY (code);


--
-- Name: customer_account_holder customer_account_holder_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_account_holder
    ADD CONSTRAINT customer_account_holder_pkey PRIMARY KEY (customer_id, account_holder_id);


--
-- Name: customer_address customer_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_pkey PRIMARY KEY (id);


--
-- Name: customer_group_customer customer_group_customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_pkey PRIMARY KEY (id);


--
-- Name: customer_group customer_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group
    ADD CONSTRAINT customer_group_pkey PRIMARY KEY (id);


--
-- Name: customer customer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_address fulfillment_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_address
    ADD CONSTRAINT fulfillment_address_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_item fulfillment_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_label fulfillment_label_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_pkey PRIMARY KEY (id);


--
-- Name: fulfillment fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_provider fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_provider
    ADD CONSTRAINT fulfillment_provider_pkey PRIMARY KEY (id);


--
-- Name: fulfillment_set fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_set
    ADD CONSTRAINT fulfillment_set_pkey PRIMARY KEY (id);


--
-- Name: geo_zone geo_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_pkey PRIMARY KEY (id);


--
-- Name: image image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_pkey PRIMARY KEY (id);


--
-- Name: inventory_item inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_item
    ADD CONSTRAINT inventory_item_pkey PRIMARY KEY (id);


--
-- Name: inventory_level inventory_level_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_pkey PRIMARY KEY (id);


--
-- Name: invite invite_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.invite
    ADD CONSTRAINT invite_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_pkey PRIMARY KEY (id);


--
-- Name: link_module_migrations link_module_migrations_table_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.link_module_migrations
    ADD CONSTRAINT link_module_migrations_table_name_key UNIQUE (table_name);


--
-- Name: location_fulfillment_provider location_fulfillment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_fulfillment_provider
    ADD CONSTRAINT location_fulfillment_provider_pkey PRIMARY KEY (stock_location_id, fulfillment_provider_id);


--
-- Name: location_fulfillment_set location_fulfillment_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.location_fulfillment_set
    ADD CONSTRAINT location_fulfillment_set_pkey PRIMARY KEY (stock_location_id, fulfillment_set_id);


--
-- Name: mikro_orm_migrations mikro_orm_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mikro_orm_migrations
    ADD CONSTRAINT mikro_orm_migrations_pkey PRIMARY KEY (id);


--
-- Name: notification notification_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (id);


--
-- Name: notification_provider notification_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_provider
    ADD CONSTRAINT notification_provider_pkey PRIMARY KEY (id);


--
-- Name: order_address order_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_address
    ADD CONSTRAINT order_address_pkey PRIMARY KEY (id);


--
-- Name: order_cart order_cart_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_cart
    ADD CONSTRAINT order_cart_pkey PRIMARY KEY (order_id, cart_id);


--
-- Name: order_change_action order_change_action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_pkey PRIMARY KEY (id);


--
-- Name: order_change order_change_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item_image order_claim_item_image_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_claim_item_image
    ADD CONSTRAINT order_claim_item_image_pkey PRIMARY KEY (id);


--
-- Name: order_claim_item order_claim_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_claim_item
    ADD CONSTRAINT order_claim_item_pkey PRIMARY KEY (id);


--
-- Name: order_claim order_claim_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_claim
    ADD CONSTRAINT order_claim_pkey PRIMARY KEY (id);


--
-- Name: order_credit_line order_credit_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_pkey PRIMARY KEY (id);


--
-- Name: order_exchange_item order_exchange_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_exchange_item
    ADD CONSTRAINT order_exchange_item_pkey PRIMARY KEY (id);


--
-- Name: order_exchange order_exchange_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_exchange
    ADD CONSTRAINT order_exchange_pkey PRIMARY KEY (id);


--
-- Name: order_fulfillment order_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_fulfillment
    ADD CONSTRAINT order_fulfillment_pkey PRIMARY KEY (order_id, fulfillment_id);


--
-- Name: order_item order_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_adjustment order_line_item_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_line_item order_line_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_pkey PRIMARY KEY (id);


--
-- Name: order_line_item_tax_line order_line_item_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_payment_collection order_payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_payment_collection
    ADD CONSTRAINT order_payment_collection_pkey PRIMARY KEY (order_id, payment_collection_id);


--
-- Name: order order_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_pkey PRIMARY KEY (id);


--
-- Name: order_promotion order_promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_promotion
    ADD CONSTRAINT order_promotion_pkey PRIMARY KEY (order_id, promotion_id);


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method order_shipping_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method
    ADD CONSTRAINT order_shipping_method_pkey PRIMARY KEY (id);


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_pkey PRIMARY KEY (id);


--
-- Name: order_shipping order_shipping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_pkey PRIMARY KEY (id);


--
-- Name: order_summary order_summary_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_summary
    ADD CONSTRAINT order_summary_pkey PRIMARY KEY (id);


--
-- Name: order_transaction order_transaction_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_pkey PRIMARY KEY (id);


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_pkey PRIMARY KEY (payment_collection_id, payment_provider_id);


--
-- Name: payment_collection payment_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_collection
    ADD CONSTRAINT payment_collection_pkey PRIMARY KEY (id);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);


--
-- Name: payment_provider payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_provider
    ADD CONSTRAINT payment_provider_pkey PRIMARY KEY (id);


--
-- Name: payment_session payment_session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_pkey PRIMARY KEY (id);


--
-- Name: price_list price_list_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_list
    ADD CONSTRAINT price_list_pkey PRIMARY KEY (id);


--
-- Name: price_list_rule price_list_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_pkey PRIMARY KEY (id);


--
-- Name: price price_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_pkey PRIMARY KEY (id);


--
-- Name: price_preference price_preference_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_preference
    ADD CONSTRAINT price_preference_pkey PRIMARY KEY (id);


--
-- Name: price_rule price_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_pkey PRIMARY KEY (id);


--
-- Name: price_set price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_set
    ADD CONSTRAINT price_set_pkey PRIMARY KEY (id);


--
-- Name: product_category product_category_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_pkey PRIMARY KEY (id);


--
-- Name: product_category_product product_category_product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_pkey PRIMARY KEY (product_id, product_category_id);


--
-- Name: product_collection product_collection_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_collection
    ADD CONSTRAINT product_collection_pkey PRIMARY KEY (id);


--
-- Name: product_option product_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_pkey PRIMARY KEY (id);


--
-- Name: product_option_value product_option_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_pkey PRIMARY KEY (id);


--
-- Name: product product_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);


--
-- Name: product_sales_channel product_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_sales_channel
    ADD CONSTRAINT product_sales_channel_pkey PRIMARY KEY (product_id, sales_channel_id);


--
-- Name: product_shipping_profile product_shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_shipping_profile
    ADD CONSTRAINT product_shipping_profile_pkey PRIMARY KEY (product_id, shipping_profile_id);


--
-- Name: product_tag product_tag_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_tag
    ADD CONSTRAINT product_tag_pkey PRIMARY KEY (id);


--
-- Name: product_tags product_tags_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_pkey PRIMARY KEY (product_id, product_tag_id);


--
-- Name: product_type product_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);


--
-- Name: product_variant_inventory_item product_variant_inventory_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_inventory_item
    ADD CONSTRAINT product_variant_inventory_item_pkey PRIMARY KEY (variant_id, inventory_item_id);


--
-- Name: product_variant_option product_variant_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_pkey PRIMARY KEY (variant_id, option_value_id);


--
-- Name: product_variant product_variant_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_pkey PRIMARY KEY (id);


--
-- Name: product_variant_price_set product_variant_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_price_set
    ADD CONSTRAINT product_variant_price_set_pkey PRIMARY KEY (variant_id, price_set_id);


--
-- Name: promotion_application_method promotion_application_method_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign_budget promotion_campaign_budget_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_pkey PRIMARY KEY (id);


--
-- Name: promotion_campaign promotion_campaign_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_campaign
    ADD CONSTRAINT promotion_campaign_pkey PRIMARY KEY (id);


--
-- Name: promotion promotion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);


--
-- Name: promotion_promotion_rule promotion_promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_pkey PRIMARY KEY (promotion_id, promotion_rule_id);


--
-- Name: promotion_rule promotion_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_rule
    ADD CONSTRAINT promotion_rule_pkey PRIMARY KEY (id);


--
-- Name: promotion_rule_value promotion_rule_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_pkey PRIMARY KEY (id);


--
-- Name: provider_identity provider_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_pkey PRIMARY KEY (id);


--
-- Name: publishable_api_key_sales_channel publishable_api_key_sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.publishable_api_key_sales_channel
    ADD CONSTRAINT publishable_api_key_sales_channel_pkey PRIMARY KEY (publishable_key_id, sales_channel_id);


--
-- Name: refund refund_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_pkey PRIMARY KEY (id);


--
-- Name: refund_reason refund_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refund_reason
    ADD CONSTRAINT refund_reason_pkey PRIMARY KEY (id);


--
-- Name: region_country region_country_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_pkey PRIMARY KEY (iso_2);


--
-- Name: region_payment_provider region_payment_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region_payment_provider
    ADD CONSTRAINT region_payment_provider_pkey PRIMARY KEY (region_id, payment_provider_id);


--
-- Name: region region_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (id);


--
-- Name: reservation_item reservation_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_pkey PRIMARY KEY (id);


--
-- Name: return_fulfillment return_fulfillment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_fulfillment
    ADD CONSTRAINT return_fulfillment_pkey PRIMARY KEY (return_id, fulfillment_id);


--
-- Name: return_item return_item_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_item
    ADD CONSTRAINT return_item_pkey PRIMARY KEY (id);


--
-- Name: return return_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return
    ADD CONSTRAINT return_pkey PRIMARY KEY (id);


--
-- Name: return_reason return_reason_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_pkey PRIMARY KEY (id);


--
-- Name: sales_channel sales_channel_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_channel
    ADD CONSTRAINT sales_channel_pkey PRIMARY KEY (id);


--
-- Name: sales_channel_stock_location sales_channel_stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sales_channel_stock_location
    ADD CONSTRAINT sales_channel_stock_location_pkey PRIMARY KEY (sales_channel_id, stock_location_id);


--
-- Name: script_migrations script_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.script_migrations
    ADD CONSTRAINT script_migrations_pkey PRIMARY KEY (id);


--
-- Name: service_zone service_zone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_pkey PRIMARY KEY (id);


--
-- Name: shipping_option shipping_option_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_price_set shipping_option_price_set_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option_price_set
    ADD CONSTRAINT shipping_option_price_set_pkey PRIMARY KEY (shipping_option_id, price_set_id);


--
-- Name: shipping_option_rule shipping_option_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_pkey PRIMARY KEY (id);


--
-- Name: shipping_option_type shipping_option_type_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option_type
    ADD CONSTRAINT shipping_option_type_pkey PRIMARY KEY (id);


--
-- Name: shipping_profile shipping_profile_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_profile
    ADD CONSTRAINT shipping_profile_pkey PRIMARY KEY (id);


--
-- Name: stock_location_address stock_location_address_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_location_address
    ADD CONSTRAINT stock_location_address_pkey PRIMARY KEY (id);


--
-- Name: stock_location stock_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_pkey PRIMARY KEY (id);


--
-- Name: store_currency store_currency_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_pkey PRIMARY KEY (id);


--
-- Name: store store_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);


--
-- Name: tax_provider tax_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_provider
    ADD CONSTRAINT tax_provider_pkey PRIMARY KEY (id);


--
-- Name: tax_rate tax_rate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT tax_rate_pkey PRIMARY KEY (id);


--
-- Name: tax_rate_rule tax_rate_rule_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT tax_rate_rule_pkey PRIMARY KEY (id);


--
-- Name: tax_region tax_region_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT tax_region_pkey PRIMARY KEY (id);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- Name: IDX_account_holder_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_account_holder_deleted_at" ON public.account_holder USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_account_holder_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_account_holder_id_5cb3a0c0" ON public.customer_account_holder USING btree (account_holder_id);


--
-- Name: IDX_account_holder_provider_id_external_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_account_holder_provider_id_external_id_unique" ON public.account_holder USING btree (provider_id, external_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_adjustment_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_adjustment_item_id" ON public.cart_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_adjustment_shipping_method_id" ON public.cart_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_api_key_deleted_at" ON public.api_key USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_api_key_token_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_api_key_token_unique" ON public.api_key USING btree (token);


--
-- Name: IDX_api_key_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_api_key_type" ON public.api_key USING btree (type);


--
-- Name: IDX_application_method_allocation; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_application_method_allocation" ON public.promotion_application_method USING btree (allocation);


--
-- Name: IDX_application_method_target_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_application_method_target_type" ON public.promotion_application_method USING btree (target_type);


--
-- Name: IDX_application_method_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_application_method_type" ON public.promotion_application_method USING btree (type);


--
-- Name: IDX_auth_identity_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_auth_identity_deleted_at" ON public.auth_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_campaign_budget_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_campaign_budget_type" ON public.promotion_campaign_budget USING btree (type);


--
-- Name: IDX_capture_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_capture_deleted_at" ON public.capture USING btree (deleted_at);


--
-- Name: IDX_capture_payment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_capture_payment_id" ON public.capture USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_address_deleted_at" ON public.cart_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_billing_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_billing_address_id" ON public.cart USING btree (billing_address_id) WHERE ((deleted_at IS NULL) AND (billing_address_id IS NOT NULL));


--
-- Name: IDX_cart_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_currency_code" ON public.cart USING btree (currency_code);


--
-- Name: IDX_cart_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_customer_id" ON public.cart USING btree (customer_id) WHERE ((deleted_at IS NULL) AND (customer_id IS NOT NULL));


--
-- Name: IDX_cart_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_deleted_at" ON public.cart USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_id_-4a39f6c9" ON public.cart_payment_collection USING btree (cart_id);


--
-- Name: IDX_cart_id_-71069c16; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_id_-71069c16" ON public.order_cart USING btree (cart_id);


--
-- Name: IDX_cart_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_id_-a9d4a70b" ON public.cart_promotion USING btree (cart_id);


--
-- Name: IDX_cart_line_item_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_adjustment_deleted_at" ON public.cart_line_item_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_adjustment_item_id" ON public.cart_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_cart_id" ON public.cart_line_item USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_line_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_deleted_at" ON public.cart_line_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_tax_line_deleted_at" ON public.cart_line_item_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_line_item_tax_line_item_id" ON public.cart_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_region_id" ON public.cart USING btree (region_id) WHERE ((deleted_at IS NULL) AND (region_id IS NOT NULL));


--
-- Name: IDX_cart_sales_channel_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_sales_channel_id" ON public.cart USING btree (sales_channel_id) WHERE ((deleted_at IS NULL) AND (sales_channel_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_address_id" ON public.cart USING btree (shipping_address_id) WHERE ((deleted_at IS NULL) AND (shipping_address_id IS NOT NULL));


--
-- Name: IDX_cart_shipping_method_adjustment_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_deleted_at" ON public.cart_shipping_method_adjustment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_adjustment_shipping_method_id" ON public.cart_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_cart_id" ON public.cart_shipping_method USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_cart_shipping_method_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_deleted_at" ON public.cart_shipping_method USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_deleted_at" ON public.cart_shipping_method_tax_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_cart_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_cart_shipping_method_tax_line_shipping_method_id" ON public.cart_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_category_handle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_category_handle_unique" ON public.product_category USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_collection_handle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_collection_handle_unique" ON public.product_collection USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_address_customer_id" ON public.customer_address USING btree (customer_id);


--
-- Name: IDX_customer_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_address_deleted_at" ON public.customer_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_address_unique_customer_billing; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_billing" ON public.customer_address USING btree (customer_id) WHERE (is_default_billing = true);


--
-- Name: IDX_customer_address_unique_customer_shipping; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_address_unique_customer_shipping" ON public.customer_address USING btree (customer_id) WHERE (is_default_shipping = true);


--
-- Name: IDX_customer_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_deleted_at" ON public.customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_email_has_account_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_email_has_account_unique" ON public.customer USING btree (email, has_account) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_group_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_group_customer_customer_group_id" ON public.customer_group_customer USING btree (customer_group_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_customer_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_group_customer_customer_id" ON public.customer_group_customer USING btree (customer_id);


--
-- Name: IDX_customer_group_customer_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_group_customer_deleted_at" ON public.customer_group_customer USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_group_deleted_at" ON public.customer_group USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_group_name" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_group_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_customer_group_name_unique" ON public.customer_group USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_customer_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_customer_id_5cb3a0c0" ON public.customer_account_holder USING btree (customer_id);


--
-- Name: IDX_deleted_at_-1d67bae40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-1e5992737; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-1e5992737" ON public.location_fulfillment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-31ea43a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-31ea43a" ON public.return_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-4a39f6c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-4a39f6c9" ON public.cart_payment_collection USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71069c16; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-71069c16" ON public.order_cart USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-71518339; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-71518339" ON public.order_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-a9d4a70b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-a9d4a70b" ON public.cart_promotion USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e88adb96; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-e88adb96" ON public.location_fulfillment_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_-e8d2543e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_-e8d2543e" ON public.order_fulfillment USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17a262437; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_17a262437" ON public.product_shipping_profile USING btree (deleted_at);


--
-- Name: IDX_deleted_at_17b4c4e35; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_17b4c4e35" ON public.product_variant_inventory_item USING btree (deleted_at);


--
-- Name: IDX_deleted_at_1c934dab0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_1c934dab0" ON public.region_payment_provider USING btree (deleted_at);


--
-- Name: IDX_deleted_at_20b454295; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_20b454295" ON public.product_sales_channel USING btree (deleted_at);


--
-- Name: IDX_deleted_at_26d06f470; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_26d06f470" ON public.sales_channel_stock_location USING btree (deleted_at);


--
-- Name: IDX_deleted_at_52b23597; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_52b23597" ON public.product_variant_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_5cb3a0c0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_5cb3a0c0" ON public.customer_account_holder USING btree (deleted_at);


--
-- Name: IDX_deleted_at_ba32fa9c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_ba32fa9c" ON public.shipping_option_price_set USING btree (deleted_at);


--
-- Name: IDX_deleted_at_f42b9949; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_deleted_at_f42b9949" ON public.order_payment_collection USING btree (deleted_at);


--
-- Name: IDX_fulfillment_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_address_deleted_at" ON public.fulfillment_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_deleted_at" ON public.fulfillment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_id_-31ea43a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_id_-31ea43a" ON public.return_fulfillment USING btree (fulfillment_id);


--
-- Name: IDX_fulfillment_id_-e8d2543e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_id_-e8d2543e" ON public.order_fulfillment USING btree (fulfillment_id);


--
-- Name: IDX_fulfillment_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_item_deleted_at" ON public.fulfillment_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_item_fulfillment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_item_fulfillment_id" ON public.fulfillment_item USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_inventory_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_item_inventory_item_id" ON public.fulfillment_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_item_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_item_line_item_id" ON public.fulfillment_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_label_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_label_deleted_at" ON public.fulfillment_label USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_label_fulfillment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_label_fulfillment_id" ON public.fulfillment_label USING btree (fulfillment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_location_id" ON public.fulfillment USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_provider_deleted_at" ON public.fulfillment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_provider_id_-1e5992737; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_provider_id_-1e5992737" ON public.location_fulfillment_provider USING btree (fulfillment_provider_id);


--
-- Name: IDX_fulfillment_set_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_set_deleted_at" ON public.fulfillment_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_fulfillment_set_id_-e88adb96; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_set_id_-e88adb96" ON public.location_fulfillment_set USING btree (fulfillment_set_id);


--
-- Name: IDX_fulfillment_set_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_fulfillment_set_name_unique" ON public.fulfillment_set USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_fulfillment_shipping_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_fulfillment_shipping_option_id" ON public.fulfillment USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_city; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_city" ON public.geo_zone USING btree (city) WHERE ((deleted_at IS NULL) AND (city IS NOT NULL));


--
-- Name: IDX_geo_zone_country_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_country_code" ON public.geo_zone USING btree (country_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_geo_zone_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_deleted_at" ON public.geo_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_geo_zone_province_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_province_code" ON public.geo_zone USING btree (province_code) WHERE ((deleted_at IS NULL) AND (province_code IS NOT NULL));


--
-- Name: IDX_geo_zone_service_zone_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_geo_zone_service_zone_id" ON public.geo_zone USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_id_-1d67bae40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (id);


--
-- Name: IDX_id_-1e5992737; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-1e5992737" ON public.location_fulfillment_provider USING btree (id);


--
-- Name: IDX_id_-31ea43a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-31ea43a" ON public.return_fulfillment USING btree (id);


--
-- Name: IDX_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-4a39f6c9" ON public.cart_payment_collection USING btree (id);


--
-- Name: IDX_id_-71069c16; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-71069c16" ON public.order_cart USING btree (id);


--
-- Name: IDX_id_-71518339; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-71518339" ON public.order_promotion USING btree (id);


--
-- Name: IDX_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-a9d4a70b" ON public.cart_promotion USING btree (id);


--
-- Name: IDX_id_-e88adb96; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-e88adb96" ON public.location_fulfillment_set USING btree (id);


--
-- Name: IDX_id_-e8d2543e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_-e8d2543e" ON public.order_fulfillment USING btree (id);


--
-- Name: IDX_id_17a262437; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_17a262437" ON public.product_shipping_profile USING btree (id);


--
-- Name: IDX_id_17b4c4e35; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (id);


--
-- Name: IDX_id_1c934dab0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_1c934dab0" ON public.region_payment_provider USING btree (id);


--
-- Name: IDX_id_20b454295; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_20b454295" ON public.product_sales_channel USING btree (id);


--
-- Name: IDX_id_26d06f470; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_26d06f470" ON public.sales_channel_stock_location USING btree (id);


--
-- Name: IDX_id_52b23597; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_52b23597" ON public.product_variant_price_set USING btree (id);


--
-- Name: IDX_id_5cb3a0c0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_5cb3a0c0" ON public.customer_account_holder USING btree (id);


--
-- Name: IDX_id_ba32fa9c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_ba32fa9c" ON public.shipping_option_price_set USING btree (id);


--
-- Name: IDX_id_f42b9949; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_id_f42b9949" ON public.order_payment_collection USING btree (id);


--
-- Name: IDX_image_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_image_deleted_at" ON public.image USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_item_deleted_at" ON public.inventory_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_item_id_17b4c4e35; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_item_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (inventory_item_id);


--
-- Name: IDX_inventory_item_sku; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_inventory_item_sku" ON public.inventory_item USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_level_deleted_at" ON public.inventory_level USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_inventory_level_inventory_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_level_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_item_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_inventory_level_item_location" ON public.inventory_level USING btree (inventory_item_id, location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_inventory_level_location_id" ON public.inventory_level USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_inventory_level_location_id_inventory_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_inventory_level_location_id_inventory_item_id" ON public.inventory_level USING btree (inventory_item_id, location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_invite_deleted_at" ON public.invite USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_invite_email_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_invite_email_unique" ON public.invite USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_invite_token; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_invite_token" ON public.invite USING btree (token) WHERE (deleted_at IS NULL);


--
-- Name: IDX_line_item_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_adjustment_promotion_id" ON public.cart_line_item_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_line_item_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_cart_id" ON public.cart_line_item USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_line_item_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_product_id" ON public.cart_line_item USING btree (product_id) WHERE ((deleted_at IS NULL) AND (product_id IS NOT NULL));


--
-- Name: IDX_line_item_product_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_product_type_id" ON public.cart_line_item USING btree (product_type_id) WHERE ((deleted_at IS NULL) AND (product_type_id IS NOT NULL));


--
-- Name: IDX_line_item_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_tax_line_tax_rate_id" ON public.cart_line_item_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_line_item_variant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_line_item_variant_id" ON public.cart_line_item USING btree (variant_id) WHERE ((deleted_at IS NULL) AND (variant_id IS NOT NULL));


--
-- Name: IDX_notification_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_notification_deleted_at" ON public.notification USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_idempotency_key_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_notification_idempotency_key_unique" ON public.notification USING btree (idempotency_key) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_notification_provider_deleted_at" ON public.notification_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_notification_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_notification_provider_id" ON public.notification USING btree (provider_id);


--
-- Name: IDX_notification_receiver_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_notification_receiver_id" ON public.notification USING btree (receiver_id);


--
-- Name: IDX_option_product_id_title_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_option_product_id_title_unique" ON public.product_option USING btree (product_id, title) WHERE (deleted_at IS NULL);


--
-- Name: IDX_option_value_option_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_option_value_option_id_unique" ON public.product_option_value USING btree (option_id, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_address_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_address_customer_id" ON public.order_address USING btree (customer_id);


--
-- Name: IDX_order_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_address_deleted_at" ON public.order_address USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_billing_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_billing_address_id" ON public."order" USING btree (billing_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_change_action_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_claim_id" ON public.order_change_action USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_deleted_at" ON public.order_change_action USING btree (deleted_at);


--
-- Name: IDX_order_change_action_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_exchange_id" ON public.order_change_action USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_action_order_change_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_order_change_id" ON public.order_change_action USING btree (order_change_id);


--
-- Name: IDX_order_change_action_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_order_id" ON public.order_change_action USING btree (order_id);


--
-- Name: IDX_order_change_action_ordering; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_ordering" ON public.order_change_action USING btree (ordering);


--
-- Name: IDX_order_change_action_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_action_return_id" ON public.order_change_action USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_change_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_change_type" ON public.order_change USING btree (change_type);


--
-- Name: IDX_order_change_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_claim_id" ON public.order_change USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_deleted_at" ON public.order_change USING btree (deleted_at);


--
-- Name: IDX_order_change_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_exchange_id" ON public.order_change USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_order_id" ON public.order_change USING btree (order_id);


--
-- Name: IDX_order_change_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_order_id_version" ON public.order_change USING btree (order_id, version);


--
-- Name: IDX_order_change_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_return_id" ON public.order_change USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_change_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_change_status" ON public.order_change USING btree (status);


--
-- Name: IDX_order_claim_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_deleted_at" ON public.order_claim USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_display_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_display_id" ON public.order_claim USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_claim_id" ON public.order_claim_item USING btree (claim_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_deleted_at" ON public.order_claim_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_item_image_claim_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_image_claim_item_id" ON public.order_claim_item_image USING btree (claim_item_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_claim_item_image_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_image_deleted_at" ON public.order_claim_item_image USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_claim_item_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_item_item_id" ON public.order_claim_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_order_id" ON public.order_claim USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_claim_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_claim_return_id" ON public.order_claim USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_credit_line_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_credit_line_deleted_at" ON public.order_credit_line USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_credit_line_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_credit_line_order_id" ON public.order_credit_line USING btree (order_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_currency_code" ON public."order" USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_customer_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_customer_id" ON public."order" USING btree (customer_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_deleted_at" ON public."order" USING btree (deleted_at);


--
-- Name: IDX_order_display_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_display_id" ON public."order" USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_deleted_at" ON public.order_exchange USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_display_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_display_id" ON public.order_exchange USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_item_deleted_at" ON public.order_exchange_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_item_exchange_id" ON public.order_exchange_item USING btree (exchange_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_item_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_item_item_id" ON public.order_exchange_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_order_id" ON public.order_exchange USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_exchange_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_exchange_return_id" ON public.order_exchange USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_id_-71069c16; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_id_-71069c16" ON public.order_cart USING btree (order_id);


--
-- Name: IDX_order_id_-71518339; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_id_-71518339" ON public.order_promotion USING btree (order_id);


--
-- Name: IDX_order_id_-e8d2543e; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_id_-e8d2543e" ON public.order_fulfillment USING btree (order_id);


--
-- Name: IDX_order_id_f42b9949; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_id_f42b9949" ON public.order_payment_collection USING btree (order_id);


--
-- Name: IDX_order_is_draft_order; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_is_draft_order" ON public."order" USING btree (is_draft_order) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_item_deleted_at" ON public.order_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_item_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_item_item_id" ON public.order_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_item_order_id" ON public.order_item USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_item_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_item_order_id_version" ON public.order_item USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_adjustment_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_line_item_adjustment_item_id" ON public.order_line_item_adjustment USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_line_item_product_id" ON public.order_line_item USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_tax_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_line_item_tax_line_item_id" ON public.order_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_line_item_variant_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_line_item_variant_id" ON public.order_line_item USING btree (variant_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_region_id" ON public."order" USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_address_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_address_id" ON public."order" USING btree (shipping_address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_claim_id" ON public.order_shipping USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_deleted_at" ON public.order_shipping USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_shipping_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_exchange_id" ON public.order_shipping USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_shipping_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_item_id" ON public.order_shipping USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_adjustment_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_method_adjustment_shipping_method_id" ON public.order_shipping_method_adjustment USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_shipping_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_method_shipping_option_id" ON public.order_shipping_method USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_method_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_method_tax_line_shipping_method_id" ON public.order_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_order_id" ON public.order_shipping USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_order_id_version" ON public.order_shipping USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_shipping_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_shipping_return_id" ON public.order_shipping USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_summary_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_summary_deleted_at" ON public.order_summary USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_order_summary_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_summary_order_id_version" ON public.order_summary USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_claim_id" ON public.order_transaction USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_currency_code" ON public.order_transaction USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_exchange_id" ON public.order_transaction USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_order_transaction_order_id_version; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_order_id_version" ON public.order_transaction USING btree (order_id, version) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_reference_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_reference_id" ON public.order_transaction USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_order_transaction_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_order_transaction_return_id" ON public.order_transaction USING btree (return_id) WHERE ((return_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_payment_collection_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_collection_deleted_at" ON public.payment_collection USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_collection_id_-4a39f6c9; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_collection_id_-4a39f6c9" ON public.cart_payment_collection USING btree (payment_collection_id);


--
-- Name: IDX_payment_collection_id_f42b9949; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_collection_id_f42b9949" ON public.order_payment_collection USING btree (payment_collection_id);


--
-- Name: IDX_payment_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_deleted_at" ON public.payment USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_payment_payment_collection_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_payment_collection_id" ON public.payment USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_payment_session_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_payment_session_id" ON public.payment USING btree (payment_session_id);


--
-- Name: IDX_payment_payment_session_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_payment_payment_session_id_unique" ON public.payment USING btree (payment_session_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_provider_deleted_at" ON public.payment_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_provider_id" ON public.payment USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_payment_provider_id_1c934dab0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_provider_id_1c934dab0" ON public.region_payment_provider USING btree (payment_provider_id);


--
-- Name: IDX_payment_session_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_session_deleted_at" ON public.payment_session USING btree (deleted_at);


--
-- Name: IDX_payment_session_payment_collection_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_payment_session_payment_collection_id" ON public.payment_session USING btree (payment_collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_currency_code" ON public.price USING btree (currency_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_deleted_at" ON public.price USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_list_deleted_at" ON public.price_list USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_list_rule_deleted_at" ON public.price_list_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_list_rule_price_list_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_list_rule_price_list_id" ON public.price_list_rule USING btree (price_list_id) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_preference_attribute_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_price_preference_attribute_value" ON public.price_preference USING btree (attribute, value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_preference_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_preference_deleted_at" ON public.price_preference USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_price_list_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_price_list_id" ON public.price USING btree (price_list_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_price_set_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_price_set_id" ON public.price USING btree (price_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_deleted_at" ON public.price_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_rule_operator; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_operator" ON public.price_rule USING btree (operator);


--
-- Name: IDX_price_rule_price_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_rule_price_id" ON public.price_rule USING btree (price_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_rule_price_id_attribute_operator_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_price_rule_price_id_attribute_operator_unique" ON public.price_rule USING btree (price_id, attribute, operator) WHERE (deleted_at IS NULL);


--
-- Name: IDX_price_set_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_set_deleted_at" ON public.price_set USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_price_set_id_52b23597; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_set_id_52b23597" ON public.product_variant_price_set USING btree (price_set_id);


--
-- Name: IDX_price_set_id_ba32fa9c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_price_set_id_ba32fa9c" ON public.shipping_option_price_set USING btree (price_set_id);


--
-- Name: IDX_product_category_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_category_deleted_at" ON public.product_collection USING btree (deleted_at);


--
-- Name: IDX_product_category_parent_category_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_category_parent_category_id" ON public.product_category USING btree (parent_category_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_category_path; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_category_path" ON public.product_category USING btree (mpath) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_collection_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_collection_deleted_at" ON public.product_collection USING btree (deleted_at);


--
-- Name: IDX_product_collection_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_collection_id" ON public.product USING btree (collection_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_deleted_at" ON public.product USING btree (deleted_at);


--
-- Name: IDX_product_handle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_handle_unique" ON public.product USING btree (handle) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_id_17a262437; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_id_17a262437" ON public.product_shipping_profile USING btree (product_id);


--
-- Name: IDX_product_id_20b454295; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_id_20b454295" ON public.product_sales_channel USING btree (product_id);


--
-- Name: IDX_product_image_url; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_image_url" ON public.image USING btree (url) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_option_deleted_at" ON public.product_option USING btree (deleted_at);


--
-- Name: IDX_product_option_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_option_product_id" ON public.product_option USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_option_value_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_option_value_deleted_at" ON public.product_option_value USING btree (deleted_at);


--
-- Name: IDX_product_option_value_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_option_value_option_id" ON public.product_option_value USING btree (option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_tag_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_tag_deleted_at" ON public.product_tag USING btree (deleted_at);


--
-- Name: IDX_product_type_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_type_deleted_at" ON public.product_type USING btree (deleted_at);


--
-- Name: IDX_product_type_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_type_id" ON public.product USING btree (type_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_barcode_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_variant_barcode_unique" ON public.product_variant USING btree (barcode) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_variant_deleted_at" ON public.product_variant USING btree (deleted_at);


--
-- Name: IDX_product_variant_ean_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_variant_ean_unique" ON public.product_variant USING btree (ean) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_product_variant_product_id" ON public.product_variant USING btree (product_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_sku_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_variant_sku_unique" ON public.product_variant USING btree (sku) WHERE (deleted_at IS NULL);


--
-- Name: IDX_product_variant_upc_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_product_variant_upc_unique" ON public.product_variant USING btree (upc) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_currency_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_application_method_currency_code" ON public.promotion_application_method USING btree (currency_code) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_promotion_application_method_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_application_method_deleted_at" ON public.promotion_application_method USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_application_method_promotion_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_promotion_application_method_promotion_id_unique" ON public.promotion_application_method USING btree (promotion_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_campaign_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_budget_campaign_id_unique" ON public.promotion_campaign_budget USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_budget_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_campaign_budget_deleted_at" ON public.promotion_campaign_budget USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_campaign_identifier_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_promotion_campaign_campaign_identifier_unique" ON public.promotion_campaign USING btree (campaign_identifier) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_campaign_deleted_at" ON public.promotion_campaign USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_campaign_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_campaign_id" ON public.promotion USING btree (campaign_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_code" ON public.promotion USING btree (code);


--
-- Name: IDX_promotion_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_deleted_at" ON public.promotion USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_id_-71518339; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_id_-71518339" ON public.order_promotion USING btree (promotion_id);


--
-- Name: IDX_promotion_id_-a9d4a70b; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_id_-a9d4a70b" ON public.cart_promotion USING btree (promotion_id);


--
-- Name: IDX_promotion_rule_attribute; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_attribute" ON public.promotion_rule USING btree (attribute);


--
-- Name: IDX_promotion_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_deleted_at" ON public.promotion_rule USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_operator; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_operator" ON public.promotion_rule USING btree (operator);


--
-- Name: IDX_promotion_rule_value_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_value_deleted_at" ON public.promotion_rule_value USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_rule_value_promotion_rule_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_rule_value_promotion_rule_id" ON public.promotion_rule_value USING btree (promotion_rule_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_status; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_status" ON public.promotion USING btree (status) WHERE (deleted_at IS NULL);


--
-- Name: IDX_promotion_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_promotion_type" ON public.promotion USING btree (type);


--
-- Name: IDX_provider_identity_auth_identity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_provider_identity_auth_identity_id" ON public.provider_identity USING btree (auth_identity_id);


--
-- Name: IDX_provider_identity_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_provider_identity_deleted_at" ON public.provider_identity USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_provider_identity_provider_entity_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_provider_identity_provider_entity_id" ON public.provider_identity USING btree (entity_id, provider);


--
-- Name: IDX_publishable_key_id_-1d67bae40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_publishable_key_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (publishable_key_id);


--
-- Name: IDX_refund_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_refund_deleted_at" ON public.refund USING btree (deleted_at);


--
-- Name: IDX_refund_payment_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_refund_payment_id" ON public.refund USING btree (payment_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_reason_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_refund_reason_deleted_at" ON public.refund_reason USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_refund_refund_reason_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_refund_refund_reason_id" ON public.refund USING btree (refund_reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_region_country_deleted_at" ON public.region_country USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_region_country_region_id" ON public.region_country USING btree (region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_region_country_region_id_iso_2_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_region_country_region_id_iso_2_unique" ON public.region_country USING btree (region_id, iso_2);


--
-- Name: IDX_region_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_region_deleted_at" ON public.region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_region_id_1c934dab0; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_region_id_1c934dab0" ON public.region_payment_provider USING btree (region_id);


--
-- Name: IDX_reservation_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_reservation_item_deleted_at" ON public.reservation_item USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_reservation_item_inventory_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_reservation_item_inventory_item_id" ON public.reservation_item USING btree (inventory_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_reservation_item_line_item_id" ON public.reservation_item USING btree (line_item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_reservation_item_location_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_reservation_item_location_id" ON public.reservation_item USING btree (location_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_claim_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_claim_id" ON public.return USING btree (claim_id) WHERE ((claim_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_display_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_display_id" ON public.return USING btree (display_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_exchange_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_exchange_id" ON public.return USING btree (exchange_id) WHERE ((exchange_id IS NOT NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_return_id_-31ea43a; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_id_-31ea43a" ON public.return_fulfillment USING btree (return_id);


--
-- Name: IDX_return_item_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_item_deleted_at" ON public.return_item USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_item_item_id" ON public.return_item USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_reason_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_item_reason_id" ON public.return_item USING btree (reason_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_item_return_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_item_return_id" ON public.return_item USING btree (return_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_return_order_id" ON public.return USING btree (order_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_return_reason_value; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_return_reason_value" ON public.return_reason USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_sales_channel_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_sales_channel_deleted_at" ON public.sales_channel USING btree (deleted_at);


--
-- Name: IDX_sales_channel_id_-1d67bae40; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_sales_channel_id_-1d67bae40" ON public.publishable_api_key_sales_channel USING btree (sales_channel_id);


--
-- Name: IDX_sales_channel_id_20b454295; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_sales_channel_id_20b454295" ON public.product_sales_channel USING btree (sales_channel_id);


--
-- Name: IDX_sales_channel_id_26d06f470; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_sales_channel_id_26d06f470" ON public.sales_channel_stock_location USING btree (sales_channel_id);


--
-- Name: IDX_service_zone_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_service_zone_deleted_at" ON public.service_zone USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_service_zone_fulfillment_set_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_service_zone_fulfillment_set_id" ON public.service_zone USING btree (fulfillment_set_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_service_zone_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_service_zone_name_unique" ON public.service_zone USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_method_adjustment_promotion_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_method_adjustment_promotion_id" ON public.cart_shipping_method_adjustment USING btree (promotion_id) WHERE ((deleted_at IS NULL) AND (promotion_id IS NOT NULL));


--
-- Name: IDX_shipping_method_cart_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_method_cart_id" ON public.cart_shipping_method USING btree (cart_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_method_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_method_option_id" ON public.cart_shipping_method USING btree (shipping_option_id) WHERE ((deleted_at IS NULL) AND (shipping_option_id IS NOT NULL));


--
-- Name: IDX_shipping_method_tax_line_tax_rate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_method_tax_line_tax_rate_id" ON public.cart_shipping_method_tax_line USING btree (tax_rate_id) WHERE ((deleted_at IS NULL) AND (tax_rate_id IS NOT NULL));


--
-- Name: IDX_shipping_option_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_deleted_at" ON public.shipping_option USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_id_ba32fa9c; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_id_ba32fa9c" ON public.shipping_option_price_set USING btree (shipping_option_id);


--
-- Name: IDX_shipping_option_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_provider_id" ON public.shipping_option USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_rule_deleted_at" ON public.shipping_option_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_option_rule_shipping_option_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_rule_shipping_option_id" ON public.shipping_option_rule USING btree (shipping_option_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_service_zone_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_service_zone_id" ON public.shipping_option USING btree (service_zone_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_shipping_profile_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_shipping_profile_id" ON public.shipping_option USING btree (shipping_profile_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_shipping_option_type_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_option_type_deleted_at" ON public.shipping_option_type USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_profile_deleted_at" ON public.shipping_profile USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_shipping_profile_id_17a262437; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_shipping_profile_id_17a262437" ON public.product_shipping_profile USING btree (shipping_profile_id);


--
-- Name: IDX_shipping_profile_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_shipping_profile_name_unique" ON public.shipping_profile USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: IDX_single_default_region; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_single_default_region" ON public.tax_rate USING btree (tax_region_id) WHERE ((is_default = true) AND (deleted_at IS NULL));


--
-- Name: IDX_stock_location_address_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_address_deleted_at" ON public.stock_location_address USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_address_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_stock_location_address_id_unique" ON public.stock_location USING btree (address_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_stock_location_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_deleted_at" ON public.stock_location USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_stock_location_id_-1e5992737; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_id_-1e5992737" ON public.location_fulfillment_provider USING btree (stock_location_id);


--
-- Name: IDX_stock_location_id_-e88adb96; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_id_-e88adb96" ON public.location_fulfillment_set USING btree (stock_location_id);


--
-- Name: IDX_stock_location_id_26d06f470; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_stock_location_id_26d06f470" ON public.sales_channel_stock_location USING btree (stock_location_id);


--
-- Name: IDX_store_currency_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_store_currency_deleted_at" ON public.store_currency USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_store_currency_store_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_store_currency_store_id" ON public.store_currency USING btree (store_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_store_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_store_deleted_at" ON public.store USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tag_value_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_tag_value_unique" ON public.product_tag USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_line_item_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_line_item_id" ON public.cart_line_item_tax_line USING btree (item_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_line_shipping_method_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_line_shipping_method_id" ON public.cart_shipping_method_tax_line USING btree (shipping_method_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_provider_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_provider_deleted_at" ON public.tax_provider USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_deleted_at" ON public.tax_rate USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_rule_deleted_at" ON public.tax_rate_rule USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_rate_rule_reference_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_rule_reference_id" ON public.tax_rate_rule USING btree (reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_tax_rate_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_rule_tax_rate_id" ON public.tax_rate_rule USING btree (tax_rate_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_rule_unique_rate_reference; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_tax_rate_rule_unique_rate_reference" ON public.tax_rate_rule USING btree (tax_rate_id, reference_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_rate_tax_region_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_rate_tax_region_id" ON public.tax_rate USING btree (tax_region_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_region_deleted_at" ON public.tax_region USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_tax_region_parent_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_region_parent_id" ON public.tax_region USING btree (parent_id);


--
-- Name: IDX_tax_region_provider_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_tax_region_provider_id" ON public.tax_region USING btree (provider_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_tax_region_unique_country_nullable_province; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_nullable_province" ON public.tax_region USING btree (country_code) WHERE ((province_code IS NULL) AND (deleted_at IS NULL));


--
-- Name: IDX_tax_region_unique_country_province; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_tax_region_unique_country_province" ON public.tax_region USING btree (country_code, province_code) WHERE (deleted_at IS NULL);


--
-- Name: IDX_type_value_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_type_value_unique" ON public.product_type USING btree (value) WHERE (deleted_at IS NULL);


--
-- Name: IDX_user_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_user_deleted_at" ON public."user" USING btree (deleted_at) WHERE (deleted_at IS NOT NULL);


--
-- Name: IDX_user_email_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX "IDX_user_email_unique" ON public."user" USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: IDX_variant_id_17b4c4e35; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_variant_id_17b4c4e35" ON public.product_variant_inventory_item USING btree (variant_id);


--
-- Name: IDX_variant_id_52b23597; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_variant_id_52b23597" ON public.product_variant_price_set USING btree (variant_id);


--
-- Name: IDX_workflow_execution_deleted_at; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_deleted_at" ON public.workflow_execution USING btree (deleted_at) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_id" ON public.workflow_execution USING btree (id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_state; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_state" ON public.workflow_execution USING btree (state) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_transaction_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_transaction_id" ON public.workflow_execution USING btree (transaction_id) WHERE (deleted_at IS NULL);


--
-- Name: IDX_workflow_execution_workflow_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX "IDX_workflow_execution_workflow_id" ON public.workflow_execution USING btree (workflow_id) WHERE (deleted_at IS NULL);


--
-- Name: idx_script_name_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_script_name_unique ON public.script_migrations USING btree (script_name);


--
-- Name: tax_rate_rule FK_tax_rate_rule_tax_rate_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate_rule
    ADD CONSTRAINT "FK_tax_rate_rule_tax_rate_id" FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rate(id) ON DELETE CASCADE;


--
-- Name: tax_rate FK_tax_rate_tax_region_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_rate
    ADD CONSTRAINT "FK_tax_rate_tax_region_id" FOREIGN KEY (tax_region_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_parent_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_parent_id" FOREIGN KEY (parent_id) REFERENCES public.tax_region(id) ON DELETE CASCADE;


--
-- Name: tax_region FK_tax_region_provider_id; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.tax_region
    ADD CONSTRAINT "FK_tax_region_provider_id" FOREIGN KEY (provider_id) REFERENCES public.tax_provider(id) ON DELETE SET NULL;


--
-- Name: application_method_buy_rules application_method_buy_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_buy_rules application_method_buy_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_buy_rules
    ADD CONSTRAINT application_method_buy_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_application_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_application_method_id_foreign FOREIGN KEY (application_method_id) REFERENCES public.promotion_application_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: application_method_target_rules application_method_target_rules_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.application_method_target_rules
    ADD CONSTRAINT application_method_target_rules_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: capture capture_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.capture
    ADD CONSTRAINT capture_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_line_item_adjustment cart_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item_adjustment
    ADD CONSTRAINT cart_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item cart_line_item_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item
    ADD CONSTRAINT cart_line_item_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_line_item_tax_line cart_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_line_item_tax_line
    ADD CONSTRAINT cart_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.cart_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart cart_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart
    ADD CONSTRAINT cart_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.cart_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: cart_shipping_method_adjustment cart_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method_adjustment
    ADD CONSTRAINT cart_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method cart_shipping_method_cart_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method
    ADD CONSTRAINT cart_shipping_method_cart_id_foreign FOREIGN KEY (cart_id) REFERENCES public.cart(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: cart_shipping_method_tax_line cart_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cart_shipping_method_tax_line
    ADD CONSTRAINT cart_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.cart_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_address customer_address_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_address
    ADD CONSTRAINT customer_address_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_group_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_group_id_foreign FOREIGN KEY (customer_group_id) REFERENCES public.customer_group(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: customer_group_customer customer_group_customer_customer_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_group_customer
    ADD CONSTRAINT customer_group_customer_customer_id_foreign FOREIGN KEY (customer_id) REFERENCES public.customer(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_delivery_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_delivery_address_id_foreign FOREIGN KEY (delivery_address_id) REFERENCES public.fulfillment_address(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment_item fulfillment_item_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_item
    ADD CONSTRAINT fulfillment_item_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment_label fulfillment_label_fulfillment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment_label
    ADD CONSTRAINT fulfillment_label_fulfillment_id_foreign FOREIGN KEY (fulfillment_id) REFERENCES public.fulfillment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: fulfillment fulfillment_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: fulfillment fulfillment_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fulfillment
    ADD CONSTRAINT fulfillment_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: geo_zone geo_zone_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.geo_zone
    ADD CONSTRAINT geo_zone_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: image image_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image
    ADD CONSTRAINT image_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: inventory_level inventory_level_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.inventory_level
    ADD CONSTRAINT inventory_level_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: notification notification_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification
    ADD CONSTRAINT notification_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.notification_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: order order_billing_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_billing_address_id_foreign FOREIGN KEY (billing_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_change_action order_change_action_order_change_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change_action
    ADD CONSTRAINT order_change_action_order_change_id_foreign FOREIGN KEY (order_change_id) REFERENCES public.order_change(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_change order_change_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_change
    ADD CONSTRAINT order_change_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_credit_line order_credit_line_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_credit_line
    ADD CONSTRAINT order_credit_line_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE;


--
-- Name: order_item order_item_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_item order_item_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_item
    ADD CONSTRAINT order_item_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_adjustment order_line_item_adjustment_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item_adjustment
    ADD CONSTRAINT order_line_item_adjustment_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item_tax_line order_line_item_tax_line_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item_tax_line
    ADD CONSTRAINT order_line_item_tax_line_item_id_foreign FOREIGN KEY (item_id) REFERENCES public.order_line_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_line_item order_line_item_totals_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_line_item
    ADD CONSTRAINT order_line_item_totals_id_foreign FOREIGN KEY (totals_id) REFERENCES public.order_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order order_shipping_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public."order"
    ADD CONSTRAINT order_shipping_address_id_foreign FOREIGN KEY (shipping_address_id) REFERENCES public.order_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping_method_adjustment order_shipping_method_adjustment_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method_adjustment
    ADD CONSTRAINT order_shipping_method_adjustment_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping_method_tax_line order_shipping_method_tax_line_shipping_method_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping_method_tax_line
    ADD CONSTRAINT order_shipping_method_tax_line_shipping_method_id_foreign FOREIGN KEY (shipping_method_id) REFERENCES public.order_shipping_method(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_shipping order_shipping_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_shipping
    ADD CONSTRAINT order_shipping_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: order_transaction order_transaction_order_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_transaction
    ADD CONSTRAINT order_transaction_order_id_foreign FOREIGN KEY (order_id) REFERENCES public."order"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_col_aa276_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_col_aa276_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_collection_payment_providers payment_collection_payment_providers_payment_pro_2d555_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_collection_payment_providers
    ADD CONSTRAINT payment_collection_payment_providers_payment_pro_2d555_foreign FOREIGN KEY (payment_provider_id) REFERENCES public.payment_provider(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment payment_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: payment_session payment_session_payment_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payment_session
    ADD CONSTRAINT payment_session_payment_collection_id_foreign FOREIGN KEY (payment_collection_id) REFERENCES public.payment_collection(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_list_rule price_list_rule_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_list_rule
    ADD CONSTRAINT price_list_rule_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_list_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_list_id_foreign FOREIGN KEY (price_list_id) REFERENCES public.price_list(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price price_price_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price
    ADD CONSTRAINT price_price_set_id_foreign FOREIGN KEY (price_set_id) REFERENCES public.price_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: price_rule price_rule_price_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.price_rule
    ADD CONSTRAINT price_rule_price_id_foreign FOREIGN KEY (price_id) REFERENCES public.price(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category product_category_parent_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category
    ADD CONSTRAINT product_category_parent_category_id_foreign FOREIGN KEY (parent_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_category_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_category_id_foreign FOREIGN KEY (product_category_id) REFERENCES public.product_category(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_category_product product_category_product_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_category_product
    ADD CONSTRAINT product_category_product_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_collection_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_collection_id_foreign FOREIGN KEY (collection_id) REFERENCES public.product_collection(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_option product_option_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_option
    ADD CONSTRAINT product_option_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_option_value product_option_value_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_option_value
    ADD CONSTRAINT product_option_value_option_id_foreign FOREIGN KEY (option_id) REFERENCES public.product_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_tags product_tags_product_tag_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_tags
    ADD CONSTRAINT product_tags_product_tag_id_foreign FOREIGN KEY (product_tag_id) REFERENCES public.product_tag(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product product_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_type_id_foreign FOREIGN KEY (type_id) REFERENCES public.product_type(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: product_variant_option product_variant_option_option_value_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_option_value_id_foreign FOREIGN KEY (option_value_id) REFERENCES public.product_option_value(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant_option product_variant_option_variant_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant_option
    ADD CONSTRAINT product_variant_option_variant_id_foreign FOREIGN KEY (variant_id) REFERENCES public.product_variant(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: product_variant product_variant_product_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variant
    ADD CONSTRAINT product_variant_product_id_foreign FOREIGN KEY (product_id) REFERENCES public.product(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_application_method promotion_application_method_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_application_method
    ADD CONSTRAINT promotion_application_method_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_campaign_budget promotion_campaign_budget_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_campaign_budget
    ADD CONSTRAINT promotion_campaign_budget_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion promotion_campaign_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_campaign_id_foreign FOREIGN KEY (campaign_id) REFERENCES public.promotion_campaign(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_id_foreign FOREIGN KEY (promotion_id) REFERENCES public.promotion(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_promotion_rule promotion_promotion_rule_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_promotion_rule
    ADD CONSTRAINT promotion_promotion_rule_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: promotion_rule_value promotion_rule_value_promotion_rule_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.promotion_rule_value
    ADD CONSTRAINT promotion_rule_value_promotion_rule_id_foreign FOREIGN KEY (promotion_rule_id) REFERENCES public.promotion_rule(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: provider_identity provider_identity_auth_identity_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.provider_identity
    ADD CONSTRAINT provider_identity_auth_identity_id_foreign FOREIGN KEY (auth_identity_id) REFERENCES public.auth_identity(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: refund refund_payment_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.refund
    ADD CONSTRAINT refund_payment_id_foreign FOREIGN KEY (payment_id) REFERENCES public.payment(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: region_country region_country_region_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.region_country
    ADD CONSTRAINT region_country_region_id_foreign FOREIGN KEY (region_id) REFERENCES public.region(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: reservation_item reservation_item_inventory_item_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.reservation_item
    ADD CONSTRAINT reservation_item_inventory_item_id_foreign FOREIGN KEY (inventory_item_id) REFERENCES public.inventory_item(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: return_reason return_reason_parent_return_reason_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.return_reason
    ADD CONSTRAINT return_reason_parent_return_reason_id_foreign FOREIGN KEY (parent_return_reason_id) REFERENCES public.return_reason(id);


--
-- Name: service_zone service_zone_fulfillment_set_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.service_zone
    ADD CONSTRAINT service_zone_fulfillment_set_id_foreign FOREIGN KEY (fulfillment_set_id) REFERENCES public.fulfillment_set(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_provider_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_provider_id_foreign FOREIGN KEY (provider_id) REFERENCES public.fulfillment_provider(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: shipping_option_rule shipping_option_rule_shipping_option_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option_rule
    ADD CONSTRAINT shipping_option_rule_shipping_option_id_foreign FOREIGN KEY (shipping_option_id) REFERENCES public.shipping_option(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_service_zone_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_service_zone_id_foreign FOREIGN KEY (service_zone_id) REFERENCES public.service_zone(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_option_type_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_option_type_id_foreign FOREIGN KEY (shipping_option_type_id) REFERENCES public.shipping_option_type(id) ON UPDATE CASCADE;


--
-- Name: shipping_option shipping_option_shipping_profile_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shipping_option
    ADD CONSTRAINT shipping_option_shipping_profile_id_foreign FOREIGN KEY (shipping_profile_id) REFERENCES public.shipping_profile(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- Name: stock_location stock_location_address_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_location
    ADD CONSTRAINT stock_location_address_id_foreign FOREIGN KEY (address_id) REFERENCES public.stock_location_address(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: store_currency store_currency_store_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.store_currency
    ADD CONSTRAINT store_currency_store_id_foreign FOREIGN KEY (store_id) REFERENCES public.store(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

