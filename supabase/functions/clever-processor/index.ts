import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

serve(async (req) => {
  try {
    const body = await req.json();
    const eventType = body.event_type;

    if (eventType !== "CHECKOUT.ORDER.COMPLETED" && eventType !== "PAYMENT.SALE.COMPLETED") {
      return new Response("Ignored", { status: 200 });
    }

    const supabase = createClient(
      Deno.env.get("SUPABASE_URL")!,
      Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!
    );

    // Get payer email from PayPal payload
    const payerEmail =
      body.resource?.payer?.email_address ||
      body.resource?.payer_info?.email ||
      null;

    if (!payerEmail) {
      return new Response("No payer email", { status: 200 });
    }

    // Find pending featured_payment by matching user email via profiles
    const { data: profile } = await supabase
      .from("profiles")
      .select("id")
      .eq("email", payerEmail)
      .single();

    if (!profile) {
      return new Response("Profile not found", { status: 200 });
    }

    // Get the most recent pending featured payment for this user
    const { data: payment } = await supabase
      .from("featured_payments")
      .select("id, listing_id")
      .eq("user_id", profile.id)
      .eq("status", "pending")
      .order("created_at", { ascending: false })
      .limit(1)
      .single();

    if (!payment) {
      return new Response("No pending payment found", { status: 200 });
    }

    const featuredUntil = new Date();
    featuredUntil.setDate(featuredUntil.getDate() + 14); // 14 days

    // Update the listing — THIS is the missing piece
    await supabase
      .from("listings")
      .update({
        featured: true,
        featured_until: featuredUntil.toISOString(),
      })
      .eq("id", payment.listing_id);

    // Mark payment as completed
    await supabase
      .from("featured_payments")
      .update({ status: "completed" })
      .eq("id", payment.id);

    return new Response("Featured listing activated", { status: 200 });
  } catch (err) {
    return new Response(`Error: ${err.message}`, { status: 500 });
  }
});
